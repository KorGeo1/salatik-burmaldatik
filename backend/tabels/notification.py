from sqlalchemy import String, Integer
from sqlalchemy.orm import Mapped, mapped_column
from database import Base


class WheelReward(Base):
    __tablename__ = "wheel_rewards"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    reward_type: Mapped[str] = mapped_column(String)  # bonus / discount / badge
    reward_value: Mapped[str] = mapped_column(String)
    probability: Mapped[float] = mapped_column(
        Integer
    )  # Вес вероятности (целое число)