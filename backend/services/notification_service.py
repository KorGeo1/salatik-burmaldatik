import httpx
from config import settings


class NotificationService:

    @staticmethod
    async def send_notification(
        user_id: int,
        telegram_id: str,
        event: str,
        title: str,
        message: str,
    ) -> bool:
        if not telegram_id:
            return False

        payload = {
            "user_id": user_id,
            "telegram_id": telegram_id,
            "event": event,
            "title": title,
            "message": message,
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    settings.TELEGRAM_SERVICE_URL, json=payload, timeout=5.0
                )
                return response.status_code == 200
        except Exception:
            return False