import hashlib
import hmac
import json
import secrets
import time
from urllib.parse import unquote, parse_qs

from fastapi import APIRouter, HTTPException, Header
from pydantic import BaseModel

from config import TELEGRAM_BOT_TOKEN
from services import db_service, ai_service, hh_service

router = APIRouter(prefix="/api", tags=["miniapp"])

# ─── JWT-like token (simple HMAC) ───

TOKEN_SECRET = TELEGRAM_BOT_TOKEN.encode()  # reuse bot token as secret
TOKEN_TTL = 30 * 24 * 3600  # 30 days


def _make_token(user_id: int) -> str:
    payload = f"{user_id}:{int(time.time())}"
    sig = hmac.new(TOKEN_SECRET, payload.encode(), hashlib.sha256).hexdigest()[:32]
    return f"{payload}:{sig}"


def _verify_token(token: str) -> int:
    try:
        parts = token.split(":")
        if len(parts) != 3:
            raise ValueError
        user_id, ts, sig = int(parts[0]), int(parts[1]), parts[2]
        expected = hmac.new(TOKEN_SECRET, f"{user_id}:{ts}".encode(), hashlib.sha256).hexdigest()[:32]
        if not hmac.compare_digest(sig, expected):
            raise ValueError
        if time.time() - ts > TOKEN_TTL:
            raise ValueError("Token expired")
        return user_id
    except Exception:
        raise HTTPException(401, "Invalid token")


# ─── Telegram Mini App Auth ───

def validate_init_data(init_data: str) -> dict:
    parsed = parse_qs(init_data)
    check_hash = parsed.get("hash", [None])[0]
    if not check_hash:
        raise HTTPException(401, "Missing hash")

    data_pairs = []
    for key, vals in sorted(parsed.items()):
        if key != "hash":
            data_pairs.append(f"{key}={unquote(vals[0])}")
    data_check_string = "\n".join(data_pairs)

    secret = hmac.new(b"WebAppData", TELEGRAM_BOT_TOKEN.encode(), hashlib.sha256).digest()
    computed = hmac.new(secret, data_check_string.encode(), hashlib.sha256).hexdigest()

    if computed != check_hash:
        raise HTTPException(401, "Invalid hash")

    user_data = parsed.get("user", [None])[0]
    if user_data:
        return json.loads(unquote(user_data))
    raise HTTPException(401, "No user data")


def get_user_id(authorization: str = Header(None)) -> int:
    """Resolve user ID from either TG initData or Bearer token."""
    if not authorization:
        raise HTTPException(401, "No auth header")

    # Bearer token (APK)
    if authorization.startswith("Bearer "):
        token = authorization[7:]
        return _verify_token(token)

    # Telegram initData (Mini App)
    try:
        user = validate_init_data(authorization)
        return user["id"]
    except Exception:
        pass

    # Maybe raw token without Bearer prefix
    try:
        return _verify_token(authorization)
    except Exception:
        raise HTTPException(401, "Invalid authorization")


# ─── Models ───

class RegisterData(BaseModel):
    username: str
    password: str


class LoginData(BaseModel):
    username: str
    password: str


class ProfileData(BaseModel):
    name: str
    gender: str = ""
    age: int
    city: str = ""
    education: str
    interests: str
    skills: str
    theme: str = "breaking"


class ThemeData(BaseModel):
    theme: str  # "breaking" or "emo"


class ChatMessage(BaseModel):
    message: str


class VacancySearch(BaseModel):
    query: str
    experience: str = "noExperience"
    page: int = 0


# ─── Auth routes (for APK) ───

@router.post("/auth/register")
async def register(data: RegisterData):
    """Register new user for APK. Returns token."""
    if len(data.username) < 3 or len(data.password) < 4:
        raise HTTPException(400, "Username min 3 chars, password min 4 chars")

    existing = await db_service.get_user_by_username(data.username)
    if existing:
        raise HTTPException(409, "Username already taken")

    # Generate unique user_id (negative to avoid collision with TG ids)
    user_id = -abs(hash(data.username + secrets.token_hex(4))) % 10**9

    password_hash = hashlib.sha256((data.password + data.username).encode()).hexdigest()
    await db_service.save_user(tg_id=user_id, username=data.username, password_hash=password_hash)

    token = _make_token(user_id)
    return {"token": token, "user_id": user_id}


@router.post("/auth/login")
async def login(data: LoginData):
    """Login for APK. Returns token."""
    user = await db_service.get_user_by_username(data.username)
    if not user:
        raise HTTPException(401, "Wrong username or password")

    password_hash = hashlib.sha256((data.password + data.username).encode()).hexdigest()
    if user.get("password_hash") != password_hash:
        raise HTTPException(401, "Wrong username or password")

    token = _make_token(user["tg_id"])
    return {"token": token, "user_id": user["tg_id"]}


# ─── Routes ───

@router.get("/profile")
async def get_profile(authorization: str = Header(None)):
    if not authorization:
        return {"exists": False}
    try:
        uid = get_user_id(authorization)
    except HTTPException:
        return {"exists": False}
    user = await db_service.get_user(uid)
    if not user:
        return {"exists": False}
    # Strip sensitive fields
    user.pop("password_hash", None)
    user.pop("username", None)
    return {"exists": True, "profile": user}


@router.post("/profile")
async def save_profile(data: ProfileData, authorization: str = Header(None)):
    uid = get_user_id(authorization)
    await db_service.save_user(
        tg_id=uid,
        name=data.name,
        gender=data.gender,
        age=data.age,
        city=data.city,
        education=data.education,
        interests=data.interests,
        skills=data.skills,
        theme=data.theme,
    )
    return {"ok": True}


@router.post("/theme")
async def set_theme(data: ThemeData, authorization: str = Header(None)):
    uid = get_user_id(authorization)
    if data.theme not in ("breaking", "emo"):
        raise HTTPException(400, "Theme must be 'breaking' or 'emo'")
    await db_service.save_user(tg_id=uid, theme=data.theme)
    return {"ok": True, "theme": data.theme}


@router.get("/theme")
async def get_theme(authorization: str = Header(None)):
    uid = get_user_id(authorization)
    user = await db_service.get_user(uid)
    theme = (user or {}).get("theme", "breaking")
    return {"theme": theme}


@router.get("/professions")
async def get_professions(authorization: str = Header(None)):
    uid = get_user_id(authorization)
    user = await db_service.get_user(uid)
    if not user:
        raise HTTPException(400, "Profile not found")
    result = await ai_service.analyze_profile(user)
    await db_service.save_user(uid, recommended_professions=result[:500])
    return {"result": result}


@router.get("/career-plan")
async def get_career_plan(authorization: str = Header(None)):
    uid = get_user_id(authorization)
    user = await db_service.get_user(uid)
    if not user:
        raise HTTPException(400, "Profile not found")
    plan = await ai_service.build_career_plan(user)
    await db_service.save_user(uid, career_plan=plan[:1000])
    return {"result": plan}


@router.get("/skill-gap")
async def get_skill_gap(authorization: str = Header(None)):
    uid = get_user_id(authorization)
    user = await db_service.get_user(uid)
    if not user:
        raise HTTPException(400, "Profile not found")
    result = await ai_service.skill_gap_analysis(user)
    return {"result": result}


@router.post("/vacancies/scored")
async def search_vacancies_scored(data: VacancySearch, authorization: str = Header(None)):
    """Search vacancies and score them for compatibility with user profile."""
    uid = get_user_id(authorization)
    user = await db_service.get_user(uid)
    if not user:
        raise HTTPException(400, "Profile not found")
    results = await hh_service.search_vacancies(
        text=data.query,
        experience=data.experience,
        per_page=10,
        page=data.page,
    )
    items = results.get("items", [])
    if items:
        scored = await ai_service.score_vacancies(user, items)
        results["items"] = scored
    return results


@router.post("/chat")
async def chat_endpoint(data: ChatMessage, authorization: str = Header(None)):
    uid = get_user_id(authorization)
    user = await db_service.get_user(uid) or {}
    history = await db_service.get_history(uid, limit=10)

    await db_service.save_message(uid, "user", data.message)
    reply = await ai_service.chat(user, history, data.message)
    await db_service.save_message(uid, "assistant", reply)

    return {"reply": reply}


@router.post("/vacancies")
async def search_vacancies(data: VacancySearch, authorization: str = Header(None)):
    get_user_id(authorization)
    results = await hh_service.search_vacancies(
        text=data.query,
        experience=data.experience,
        per_page=10,
        page=data.page,
    )
    return results


@router.get("/vacancy-suggestions")
async def vacancy_suggestions(authorization: str = Header(None)):
    uid = get_user_id(authorization)
    user = await db_service.get_user(uid)
    if not user:
        raise HTTPException(400, "Profile not found")
    queries = await ai_service.suggest_search_queries(user)
    return {"queries": queries}
