import datetime
from sqlalchemy.orm import Session
from sqlalchemy import select
from tabels.quest import Quest, UserQuest
from tabels.user import User
from tabels.leaderboard import LeaderboardEntry
from services.notification_service import NotificationService
from telegram.telegram_service import TelegramService

class QuestService:

    @staticmethod
    def create_quest(db: Session, quest_data) -> Quest:
        db_quest = Quest(**quest_data.model_dump())
        db.add(db_quest)
        db.commit()
        db.refresh(db_quest)
        return db_quest

    @staticmethod
    def get_active_quests(db: Session):
        return db.scalars(select(Quest).where(Quest.is_active == True)).all()

    @staticmethod
    async def complete_quest(db: Session, user: User, quest_id: int) -> bool:
        quest = db.get(Quest, quest_id)
        if not quest or not quest.is_active:
            return False

        # Проверка на дублирование прохождения
        existing = db.scalar(
            select(UserQuest).where(
                UserQuest.user_id == user.id,
                UserQuest.quest_id == quest_id,
                UserQuest.completed == True,
            )
        )
        if existing and quest.quest_type == "seasonal":
            return False  # Сезонные квесты проходят 1 раз

        # Сохранение прогресса квеста
        uq = UserQuest(
            user_id=user.id,
            quest_id=quest.id,
            completed=True,
            completed_at=datetime.datetime.utcnow(),
        )
        db.add(uq)

        # Начисление наград
        user.bonus_balance += quest.reward_amount

        # Обновление лидерборда
        leaderboard_entry = db.scalar(
            select(LeaderboardEntry).where(LeaderboardEntry.user_id == user.id)
        )
        if not leaderboard_entry:
            leaderboard_entry = LeaderboardEntry(
                user_id=user.id, monthly_points=0
            )
            db.add(leaderboard_entry)
        leaderboard_entry.monthly_points += quest.reward_amount

        db.commit()

        # Триггер системного уведомления
        await NotificationService.send_notification(
            user_id=user.id,
            telegram_id=user.telegram_id,
            event="quest_completed",
            title="Квест выполнен!",
            message=f"Вы успешно завершили '{quest.title}' и получили {quest.reward_amount} бонусов.",
        )
        await TelegramService.send_notification(
            user_id=user.id,
            title="Квест выполнен!",
            message=f"Вы успешно завершили '{quest.title}' и получили {quest.reward_amount} бонусов."
        )
        return True