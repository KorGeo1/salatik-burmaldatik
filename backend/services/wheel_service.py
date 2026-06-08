import random
from sqlalchemy.orm import Session
from sqlalchemy import select
from tabels.notification import WheelReward
from tabels.user import User
from services.notification_service import NotificationService


class WheelService:

    @staticmethod
    async def spin(db: Session, user: User) -> WheelReward:
        rewards = db.scalars(select(WheelReward)).all()
        if not rewards:
            # Создаем дефолтные награды для демонстрации, если таблица пуста
            rewards = [
                WheelReward(
                    reward_type="bonus", reward_value="50", probability=50
                ),
                WheelReward(
                    reward_type="bonus", reward_value="100", probability=30
                ),
                WheelReward(
                    reward_type="discount", reward_value="10%", probability=20
                ),
            ]
            db.add_all(rewards)
            db.commit()

        # Взвешенный рандом по вероятностям
        chosen_reward = random.choices(
            rewards, weights=[r.probability for r in rewards], k=1
        )[0]

        # Применяем начисление, если это чистые бонусы
        if chosen_reward.reward_type == "bonus":
            user.bonus_balance += int(chosen_reward.reward_value)
            db.commit()

        await NotificationService.send_notification(
            user_id=user.id,
            telegram_id=user.telegram_id,
            event="wheel_spin",
            title="Колесо Фортуны",
            message=f"Вы выиграли: {chosen_reward.reward_type} ({chosen_reward.reward_value})",
        )

        return chosen_reward