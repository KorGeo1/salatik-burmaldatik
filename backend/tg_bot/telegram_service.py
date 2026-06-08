import logging
from aiogram import Bot
from database import SessionLocal
from tabels.user import User
from apscheduler.schedulers.asyncio import AsyncIOScheduler

logger = logging.getLogger(__name__)

class TelegramService:
    bot: Bot = None  # Сюда передадим инстанс бота при запуске

    @classmethod
    async def send_notification(cls, user_id: int, title: str, message: str) -> bool:
        """Метод вызывается напрямую из FastAPI (без HTTP)"""
        if not cls.bot:
            return False

        # Открываем синхронную сессию БД прямо здесь
        with SessionLocal() as db:
            user = db.query(User).filter(User.id == user_id).first()
            if not user or not user.telegram_id:
                return False  # У пользователя не привязан ТГ
            
            tg_id = user.telegram_id

        # Отправляем сообщение через aiogram
        text = f"🔔 <b>{title}</b>\n\n{message}"
        try:
            await cls.bot.send_message(chat_id=tg_id, text=text, parse_mode="HTML")
            return True
        except Exception as e:
            logger.error(f"Ошибка отправки уведомления в ТГ: {e}")
            return False

    @classmethod
    async def daily_quest_reminder(cls):
        """Та самая напоминалка квестов"""
        if not cls.bot:
            return

        with SessionLocal() as db:
            # Ищем всех пользователей, у которых привязан телеграм
            users = db.query(User).filter(User.telegram_id.is_not(None)).all()
            
            for user in users:
                text = (
                    f"Доброе утро, {user.username}! ☀️\n"
                    f"Твой баланс: {user.bonus_balance} бонусов.\n\n"
                    f"Не забудь зайти в СКС Онлайн, забрать ежедневный бонус и выполнить новые квесты!"
                )
                try:
                    await cls.bot.send_message(chat_id=user.telegram_id, text=text)
                except Exception as e:
                    logger.error(f"Не удалось отправить утреннее напоминание {user.username}: {e}")

    @classmethod
    def start_scheduler(cls):
        scheduler = AsyncIOScheduler()
        # Ставим рассылку на 09:00 утра
        scheduler.add_job(
            cls.daily_quest_reminder,
            trigger="cron",
            hour=9,
            minute=0
        )
        scheduler.start()