import datetime
from sqlalchemy import String, Integer, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from database import Base


class Reward(Base):
    __tablename__ = "rewards"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String, index=True)
    description: Mapped[str] = mapped_column(String)
    cost: Mapped[int] = mapped_column(Integer)
    stock: Mapped[int] = mapped_column(Integer)


class RewardPurchase(Base):
    __tablename__ = "reward_purchases"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id"), index=True
    )
    reward_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("rewards.id"), index=True
    )
    purchased_at: Mapped[datetime.datetime] = mapped_column(
        DateTime, default=datetime.datetime.utcnow
    )