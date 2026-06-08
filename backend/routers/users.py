import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from tabels.user import User
from routers.auth import get_current_user
from schemas.user import UserResponse
from services.notification_service import NotificationService

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.post("/daily-checkin", response_model=UserResponse)
async def daily_checkin(
    current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    now = datetime.datetime.utcnow()
    last_login = current_user.last_login

    if last_login:
        delta = now.date() - last_login.date()
        if delta.days == 0:
            raise HTTPException(
                status_code=400,
                detail="Вы уже забирали ежедневную награду сегодня.",
            )
        elif delta.days == 1:
            current_user.streak_days += 1
        else:
            current_user.streak_days = 1  # Сброс серии [cite: 49]
    else:
        current_user.streak_days = 1

    # Базовая награда за вход [cite: 47]
    reward = 5
    message = "Вы получили +5 бонусов за ежедневный вход! [cite: 47]"

    # Прогрессивные бонусы за серии [cite: 48]
    if current_user.streak_days == 7:
        reward += 50
        message = "Недельный стрик! Получено +50 экстра-бонусов! [cite: 48]"
    elif current_user.streak_days == 14:
        reward += 150
        message = "2 недели беспрерывного входа! Начислено 150 бонусов. [cite: 48]"
    elif current_user.streak_days == 30:
        reward += 500
        message = "Легенда! 30 дней в приложении, держи 500 бонусов и редкий бейдж! [cite: 48]"

    current_user.bonus_balance += reward
    current_user.last_login = now
    db.commit()

    await NotificationService.send_notification(
        user_id=current_user.id,
        telegram_id=current_user.telegram_id,
        event="streak_milestone",
        title=f"Дней подряд: {current_user.streak_days}",
        message=message,
    )

    return current_user