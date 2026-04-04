import asyncio
import logging

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from contextlib import asynccontextmanager

from aiogram import Bot, Dispatcher
from aiogram.fsm.storage.memory import MemoryStorage
from aiogram.client.default import DefaultBotProperties
from aiogram.enums import ParseMode

from config import TELEGRAM_BOT_TOKEN
from services.db_service import init_db
from api.routes import router as api_router
from bot.handlers import router as bot_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

bot = Bot(
    token=TELEGRAM_BOT_TOKEN,
    default=DefaultBotProperties(parse_mode=ParseMode.MARKDOWN),
)
dp = Dispatcher(storage=MemoryStorage())
dp.include_router(bot_router)


async def start_bot():
    logger.info("Starting Telegram bot polling...")
    await dp.start_polling(bot)


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    bot_task = asyncio.create_task(start_bot())
    logger.info("Bot and API started")
    yield
    bot_task.cancel()
    try:
        await bot_task
    except asyncio.CancelledError:
        pass
    await bot.session.close()


app = FastAPI(title="Career Bot API", lifespan=lifespan)
app.include_router(api_router)

# Serve Mini App frontend — static assets BEFORE SPA fallback
app.mount("/app/assets", StaticFiles(directory="frontend/dist/assets"), name="assets")


@app.get("/download/apk")
async def download_apk():
    return FileResponse("static/protrack.apk", filename="ProTrack.apk", media_type="application/vnd.android.package-archive")


@app.get("/app")
@app.get("/app/{path:path}")
async def serve_spa(path: str = ""):
    return FileResponse("frontend/dist/index.html")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)
