from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import select
from database import get_db
from tabels.user import User
from tabels.reward import Reward
from routers.auth import get_current_user, require_role
from schemas.reward import RewardCreate, RewardResponse
from services.reward_service import RewardService

router = APIRouter(prefix="/rewards", tags=["Rewards (Marketplace)"])


@router.get("/", response_model=list[RewardResponse])
def get_marketplace(db: Session = Depends(get_db)):
    return db.scalars(select(Reward).where(Reward.stock > 0)).all()


@router.post("/", response_model=RewardResponse)
def add_reward_to_catalog(
    reward_in: RewardCreate,
    admin_user: User = Depends(require_role(["admin"])),
    db: Session = Depends(get_db),
):
    return RewardService.create_reward(db, reward_in)


@router.post("/{reward_id}/purchase")
async def buy_reward(
    reward_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    success = await RewardService.purchase_reward(db, current_user, reward_id)
    if not success:
        raise HTTPException(
            status_code=400,
            detail="Недостаточно бонусов или товар закончился на складе.",
        )
    return {"status": "success", "message": "Приз успешно куплен!"}