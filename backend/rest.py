import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI
from database import engine, Base
from routers import (
    auth,
    users,
    quests,
    rewards,
    achievements,
    leaderboard,
    wheel,
    notifications,
)
from telegram.bot import bot, dp
from telegram.handler import router as telegram_router
from telegram.telegram_service import TelegramService

@asynccontextmanager
async def lifespan(app: FastAPI):
    dp.include_router(telegram_router)
    
    TelegramService.bot = bot

    TelegramService.start_scheduler()

    bot_task = asyncio.create_task(dp.start_polling(bot))
    
    yield

    await dp.stop_polling()
    await bot.session.close()
    bot_task.cancel()

# Автоматическое создание таблиц при запуске (для MVP хакатона)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="SKS Quest API",
    description="Backend-модуль геймификации для мобильного приложения СКС Онлайн",
    version="1.0.0",
    lifespan=lifespan
)

# Подключение маршрутизаторов модулей геймификации
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(quests.router)
app.include_router(rewards.router)
app.include_router(achievements.router)
app.include_router(leaderboard.router)
app.include_router(wheel.router)
app.include_router(notifications.router)


@app.get("/", tags=["Root"])
def read_root():
    return {
        "status": "healthy",
        "project": "SKS Quest Hackathon MVP Backend + Telegram Bot Integration",
    }