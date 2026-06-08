from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from tabels.user import User
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