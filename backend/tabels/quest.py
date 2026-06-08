import datetime
from sqlalchemy import String, Integer, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column
from database import Base


class Quest(Base):
    __tablename__ = "quests"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String, index=True)
    description: Mapped[str] = mapped_column(String)
    reward_amount: Mapped[int] = mapped_column(Integer)
    quest_type: Mapped[str] = mapped_column(String)  # daily / seasonal
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    start_date: Mapped[datetime.datetime] = mapped_column(
        DateTime, nullable=True
    )
    end_date: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=True)


class UserQuest(Base):
    __tablename__ = "user_quests"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id"), index=True
    )
    quest_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("quests.id"), index=True
    )
    completed: Mapped[bool] = mapped_column(Boolean, default=False)
    completed_at: Mapped[datetime.datetime] = mapped_column(
        DateTime, nullable=True
    )