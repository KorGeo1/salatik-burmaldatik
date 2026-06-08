import datetime
from sqlalchemy import String, Integer, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    username: Mapped[str] = mapped_column(String, unique=True, index=True)
    email: Mapped[str] = mapped_column(String, unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String)
    telegram_id: Mapped[str] = mapped_column(String, nullable=True, default=None)
    telegram_link_code: Mapped[str] = mapped_column(String, nullable=True, default=None)
    bonus_balance: Mapped[int] = mapped_column(Integer, default=0)
    streak_days: Mapped[int] = mapped_column(Integer, default=0)
    last_login: Mapped[datetime.datetime] = mapped_column(
        DateTime, nullable=True
    )
    role: Mapped[str] = mapped_column(String, default="client")