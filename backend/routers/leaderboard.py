from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from services.leaderboard_service import LeaderboardService

router = APIRouter(prefix="/leaderboard", tags=["Leaderboard"])


@router.get("/")
def get_monthly_ranking(db: Session = Depends(get_db)):
    # Возвращает анонимизированную таблицу участников для комплаенса [cite: 80, 150]
    return LeaderboardService.get_monthly_leaderboard(db)