from sqlalchemy.orm import Session
from tabels.reward import Reward, RewardPurchase
from tabels.user import User
from services.notification_service import NotificationService


class RewardService:

    @staticmethod
    def create_reward(db: Session, reward_data) -> Reward:
        db_reward = Reward(**reward_data.model_dump())
        db.add(db_reward)
        db.commit()
        db.refresh(db_reward)
        return db_reward

    @staticmethod
    async def purchase_reward(db: Session, user: User, reward_id: int) -> bool:
        reward = db.get(Reward, reward_id)
        if not reward or reward.stock <= 0 or user.bonus_balance < reward.cost:
            return False

        # Транзакционная покупка
        user.bonus_balance -= reward.cost
        reward.stock -= 1

        purchase = RewardPurchase(user_id=user.id, reward_id=reward.id)
        db.add(purchase)
        db.commit()

        await NotificationService.send_notification(
            user_id=user.id,
            telegram_id=user.telegram_id,
            event="reward_purchased",
            title="Приз приобретен",
            message=f"Вы обменяли бонусы на '{reward.title}'. Поздравляем!",
        )
        return True