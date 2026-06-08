from sqlalchemy import Integer, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column
from database import Base


class LeaderboardEntry(Base):
    __tablename__ = "leaderboard"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id"), unique=True, index=True
    )
    monthly_points: Mapped[int] = mapped_column(Integer, default=0)