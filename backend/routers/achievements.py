from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import select
from database import get_db
from tabels.user import User
from tabels.achievement import UserAchievement, Achievement
from routers.auth import get_current_user
from schemas.achievement import AchievementResponse

router = APIRouter(prefix="/achievements", tags=["Achievements"])


@router.get("/", response_model=list[AchievementResponse])
def get_my_achievements(
    current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    stmt = (
        select(Achievement)
        .join(UserAchievement, UserAchievement.achievement_id == Achievement.id)
        .where(UserAchievement.user_id == current_user.id)
    )
    return db.scalars(stmt).all()