from fastapi import APIRouter, Depends
from tabels.user import User
from routers.auth import require_role
from services.notification_service import NotificationService

router = APIRouter(prefix="/notifications", tags=["Notifications Trigger Test"])


@router.post("/trigger-reactivation")
async def trigger_reactivation_test(
    user_id: int,
    tg_id: str,
    analyst: User = Depends(require_role(["marketing", "analyst", "admin"])),
):
    # Ручной триггер маркетинга для реактивации спящих клиентов [cite: 19, 88]
    success = await NotificationService.send_notification(
        user_id=user_id,
        telegram_id=tg_id,
        event="user_reactivation",
        title="Мы скучаем!",
        message="Загляни в приложение SKS и забери подарок! [cite: 88]",
    )
    return {"notified": success}