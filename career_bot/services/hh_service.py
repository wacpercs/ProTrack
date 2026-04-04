import aiohttp

HH_API = "https://api.hh.ru"
HEADERS = {"User-Agent": "CareerTrackBot/1.0 (https://career.dimaswife.ru; career@dimaswife.ru)"}

# Популярные города -> area_id на hh.ru
CITY_AREA_MAP = {
    "москва": 1, "санкт-петербург": 2, "петербург": 2, "спб": 2,
    "новосибирск": 4, "екатеринбург": 3, "казань": 88,
    "нижний новгород": 66, "челябинск": 104, "самара": 78,
    "омск": 68, "ростов-на-дону": 76, "ростов": 76,
    "уфа": 99, "красноярск": 54, "воронеж": 26,
    "пермь": 72, "волгоград": 24, "краснодар": 53,
    "тюмень": 97, "саратов": 79, "тольятти": 92,
    "ижевск": 37, "барнаул": 14, "иркутск": 41,
    "ульяновск": 98, "хабаровск": 101, "владивосток": 22,
    "ярославль": 112, "томск": 93, "оренбург": 69,
    "кемерово": 43, "новокузнецк": 65, "рязань": 77,
    "астрахань": 15, "набережные челны": 64, "пенза": 71,
    "липецк": 57, "тула": 96, "киров": 46,
    "чебоксары": 103, "калининград": 42, "курск": 55,
    "брянск": 18, "сочи": 237, "кузбасс": 43,
}


async def resolve_city_area(city: str) -> int | None:
    """Resolve city name to hh.ru area_id. Returns None for Russia-wide."""
    normalized = city.lower().strip()
    if normalized in CITY_AREA_MAP:
        return CITY_AREA_MAP[normalized]
    # Try API suggest
    results = await suggest_areas(normalized)
    if results:
        return int(results[0]["id"])
    return None


async def search_vacancies(
    text: str,
    area: int = 113,  # 113 = Россия
    per_page: int = 10,
    page: int = 0,
    experience: str | None = None,
    schedule: str | None = None,
) -> dict:
    params = {
        "text": text,
        "area": area,
        "per_page": per_page,
        "page": page,
        "order_by": "relevance",
    }
    if experience:
        params["experience"] = experience  # noExperience, between1And3, between3And6
    if schedule:
        params["schedule"] = schedule  # fullDay, shift, flexible, remote, partTime

    async with aiohttp.ClientSession(headers=HEADERS) as session:
        async with session.get(f"{HH_API}/vacancies", params=params) as resp:
            data = await resp.json()
            return _format_vacancies(data)


def _format_vacancies(data: dict) -> dict:
    items = []
    for v in data.get("items", []):
        salary = _format_salary(v.get("salary"))
        items.append({
            "id": v["id"],
            "title": v["name"],
            "company": v.get("employer", {}).get("name", ""),
            "city": v.get("area", {}).get("name", ""),
            "salary": salary,
            "experience": v.get("experience", {}).get("name", ""),
            "schedule": v.get("schedule", {}).get("name", ""),
            "url": v.get("alternate_url", ""),
            "published": v.get("published_at", "")[:10],
        })
    return {
        "total": data.get("found", 0),
        "items": items,
    }


def _format_salary(salary: dict | None) -> str:
    if not salary:
        return "не указана"
    parts = []
    if salary.get("from"):
        parts.append(f"от {salary['from']:,}".replace(",", " "))
    if salary.get("to"):
        parts.append(f"до {salary['to']:,}".replace(",", " "))
    cur = salary.get("currency", "")
    if cur == "RUR":
        cur = "руб."
    return " ".join(parts) + f" {cur}" if parts else "не указана"


async def get_vacancy_detail(vacancy_id: str) -> dict:
    async with aiohttp.ClientSession(headers=HEADERS) as session:
        async with session.get(f"{HH_API}/vacancies/{vacancy_id}") as resp:
            v = await resp.json()
            return {
                "id": v["id"],
                "title": v["name"],
                "company": v.get("employer", {}).get("name", ""),
                "description": v.get("description", ""),
                "key_skills": [s["name"] for s in v.get("key_skills", [])],
                "experience": v.get("experience", {}).get("name", ""),
                "salary": _format_salary(v.get("salary")),
                "url": v.get("alternate_url", ""),
            }


async def suggest_areas(query: str) -> list[dict]:
    async with aiohttp.ClientSession(headers=HEADERS) as session:
        async with session.get(f"{HH_API}/suggests/areas", params={"text": query}) as resp:
            data = await resp.json()
            return [{"id": item["id"], "name": item["text"]} for item in data.get("items", [])]
