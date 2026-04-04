import aiosqlite
from config import DB_PATH

CREATE_USERS = """
CREATE TABLE IF NOT EXISTS users (
    tg_id INTEGER PRIMARY KEY,
    username TEXT UNIQUE,
    password_hash TEXT,
    name TEXT,
    gender TEXT,
    age INTEGER,
    city TEXT,
    education TEXT,
    interests TEXT,
    skills TEXT,
    recommended_professions TEXT,
    career_plan TEXT,
    theme TEXT DEFAULT 'breaking',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
"""

CREATE_HISTORY = """
CREATE TABLE IF NOT EXISTS chat_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tg_id INTEGER,
    role TEXT,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tg_id) REFERENCES users(tg_id)
)
"""


async def init_db():
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(CREATE_USERS)
        await db.execute(CREATE_HISTORY)
        # Migrate: add theme column if missing
        cursor = await db.execute("PRAGMA table_info(users)")
        columns = [row[1] for row in await cursor.fetchall()]
        if "theme" not in columns:
            await db.execute("ALTER TABLE users ADD COLUMN theme TEXT DEFAULT 'breaking'")
        await db.commit()


async def save_user(tg_id: int, **kwargs):
    fields = {k: v for k, v in kwargs.items() if v is not None}
    if not fields:
        return
    async with aiosqlite.connect(DB_PATH) as db:
        existing = await db.execute("SELECT tg_id FROM users WHERE tg_id = ?", (tg_id,))
        row = await existing.fetchone()
        if row:
            sets = ", ".join(f"{k} = ?" for k in fields)
            vals = list(fields.values()) + [tg_id]
            await db.execute(f"UPDATE users SET {sets} WHERE tg_id = ?", vals)
        else:
            fields["tg_id"] = tg_id
            cols = ", ".join(fields.keys())
            placeholders = ", ".join("?" for _ in fields)
            await db.execute(f"INSERT INTO users ({cols}) VALUES ({placeholders})", list(fields.values()))
        await db.commit()


async def get_user(tg_id: int) -> dict | None:
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute("SELECT * FROM users WHERE tg_id = ?", (tg_id,))
        row = await cursor.fetchone()
        return dict(row) if row else None


async def get_user_by_username(username: str) -> dict | None:
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute("SELECT * FROM users WHERE username = ?", (username,))
        row = await cursor.fetchone()
        return dict(row) if row else None


async def save_message(tg_id: int, role: str, content: str):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            "INSERT INTO chat_history (tg_id, role, content) VALUES (?, ?, ?)",
            (tg_id, role, content),
        )
        await db.commit()


async def get_history(tg_id: int, limit: int = 10) -> list[dict]:
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute(
            "SELECT role, content FROM chat_history WHERE tg_id = ? ORDER BY id DESC LIMIT ?",
            (tg_id, limit),
        )
        rows = await cursor.fetchall()
        return [dict(r) for r in reversed(rows)]


async def clear_history(tg_id: int):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("DELETE FROM chat_history WHERE tg_id = ?", (tg_id,))
        await db.commit()
