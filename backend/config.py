import os
from pydantic_settings import BaseSettings

# SQL "sqlite:///./sks_quest.db"
# PostgreSQL "postgresql://postgres:postgres@localhost:5432/sks_quest"

class Settings(BaseSettings):
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", "sqlite:///./sks_quest.db"
    )
    SECRET_KEY: str = os.getenv("SECRET_KEY", "SUPER_SECRET_SKS_QUEST_KEY_2026")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    TELEGRAM_SERVICE_URL: str = os.getenv(
        "TELEGRAM_SERVICE_URL", "http://localhost:8080/api/v1/notify"
    )


settings = Settings()