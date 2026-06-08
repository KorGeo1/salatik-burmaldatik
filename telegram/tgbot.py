import logging
import json
import os
from dotenv import load_dotenv
import httpx
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from apscheduler.schedulers.asyncio import AsyncIOScheduler

# Настройки
load_dotenv()
BOT_TOKEN = os.getenv("TOKEN")
BACKEND_URL = "http://your-backend.com/api/daily-message"
DB_FILE = "chat_ids.json"  # файл рядом со скриптом

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)


def load_chat_ids() -> set[int]:
    if os.path.exists(DB_FILE):
        with open(DB_FILE, "r") as f:
            return set(json.load(f))
    return set()


def save_chat_ids(chat_ids: set[int]):
    with open(DB_FILE, "w") as f:
        json.dump(list(chat_ids), f)


chat_ids: set[int] = load_chat_ids()  # ← загружаем при старте


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    chat_id = update.effective_chat.id
    username = update.effective_user.username or "без username"
    full_name = update.effective_user.full_name

    chat_ids.add(chat_id)
    save_chat_ids(chat_ids)  # ← сохраняем сразу

    logger.info(f"[/start] {full_name} (@{username}) | chat_id={chat_id}")

    await update.message.reply_text(
        f"Привет! Твой id: {chat_id}\n"
        f"Ты подписан на ежедневные сообщения ✅"
    )


async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    chat_id = update.effective_chat.id
    username = update.effective_user.username or "без username"
    full_name = update.effective_user.full_name
    text = update.message.text

    logger.info(f"[Сообщение] {full_name} (@{username}) | chat_id={chat_id} | текст: {text}")

    await update.message.reply_text(text)


async def send_daily_messages(app: Application):
    if not chat_ids:
        logger.info("Нет подписчиков, пропускаем.")
        return

    async with httpx.AsyncClient(timeout=10) as client:
        for chat_id in chat_ids:
            try:
                response = await client.post(BACKEND_URL, json={"chat_id": chat_id})
                response.raise_for_status()

                data = response.json()
                text = data.get("text", "Нет текста от сервера")

                await app.bot.send_message(chat_id=chat_id, text=text)
                logger.info(f"[Рассылка] Отправлено для chat_id={chat_id}")

            except httpx.HTTPError as e:
                logger.error(f"[Рассылка] Ошибка запроса для chat_id={chat_id}: {e}")
            except Exception as e:
                logger.error(f"[Рассылка] Неожиданная ошибка для chat_id={chat_id}: {e}")


async def post_init(app: Application):
    scheduler = AsyncIOScheduler()
    scheduler.add_job(
        send_daily_messages,
        trigger="cron",
        hour=9,
        minute=0,
        args=[app],
    )
    scheduler.start()
    logger.info(f"Планировщик запущен. Подписчиков загружено: {len(chat_ids)}")


def main():
    app = (
        Application.builder()
        .token(BOT_TOKEN)
        .post_init(post_init)
        .build()
    )

    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo))

    logger.info("Бот запущен.")
    app.run_polling()


if __name__ == "__main__":
    main()