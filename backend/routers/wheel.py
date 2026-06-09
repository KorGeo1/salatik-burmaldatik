from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from tabels.user import User
from tabels.notification import WheelReward
from routers.auth import get_current_user
from services.wheel_service import WheelService

router = APIRouter(prefix="/wheel", tags=["Wheel of Fortune"])


@router.post("/spin")
async def spin_the_wheel(
    current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    # Метод защищен лимитами вызова на фронтенде/сервисах во избежание злоупотреблений [cite: 66, 149]
    reward = await WheelService.spin(db, current_user)
    return {
        "status": "success",
        "reward_type": reward.reward_type,
        "reward_value": reward.reward_value,
    }

@router.get("/")
async def get_wheel_rewards(
    current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """
    Получить список всех доступных наград в Колесе Фортуны и их вероятности.
    """
    rewards = await WheelService.get_all_rewards(db)
    return {
        "status": "success",
        "rewards": [
            {
                "id": reward.id,  # Если у модели WheelReward есть поле id
                "reward_type": reward.reward_type,
                "reward_value": reward.reward_value,
                "probability": reward.probability
            }
            for reward in rewards
        ]
    }
