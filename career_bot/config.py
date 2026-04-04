import os
from dotenv import load_dotenv

load_dotenv()

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")
DEEPSEEK_BASE_URL = "https://api.deepseek.com"
DB_PATH = "career_bot.db"

# Mini App URL — будет доступен после деплоя (https://your-domain/app)
WEBAPP_URL = os.getenv("WEBAPP_URL", "")
