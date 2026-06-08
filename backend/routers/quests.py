from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from tabels.user import User
from routers.auth import get_current_user, require_role
from schemas.quest import QuestCreate, QuestResponse
from services.quest_service import QuestService

router = APIRouter(prefix="/quests", tags=["Quests"])


@router.get("/", response_model=list[QuestResponse])
def list_quests(db: Session = Depends(get_db)):
    return QuestService.get_active_quests(db)


@router.post("/", response_model=QuestResponse)
def create_quest(
    quest_in: QuestCreate,
    admin_user: User = Depends(require_role(["marketing", "admin"])),
    db: Session = Depends(get_db),
):
    return QuestService.create_quest(db, quest_in)


@router.post("/{quest_id}/complete")
async def complete_quest(
    quest_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    success = await QuestService.complete_quest(db, current_user, quest_id)
    if not success:
        raise HTTPException(
            status_code=400,
            detail="Не удалось выполнить квест. Он может быть неактивен или выполнен ранее.",
        )
    return {"status": "success", "message": "Награда за квест успешно зачислена."}