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

# Автоматическое создание таблиц при запуске (для MVP хакатона)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="SKS Quest API",
    description="Backend-модуль геймификации для мобильного приложения СКС Онлайн [cite: 4]",
    version="1.0.0",
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
        "project": "SKS Quest Hackathon MVP Backend ",
    }