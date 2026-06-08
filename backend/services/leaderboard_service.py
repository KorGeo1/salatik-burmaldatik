from sqlalchemy.orm import Session
from sqlalchemy import select
from tabels.leaderboard import LeaderboardEntry
from tabels.user import User


class LeaderboardService:

    @staticmethod
    def get_monthly_leaderboard(db: Session, limit: int = 100):
        # Анонимизированный вывод: возвращает маскированное имя или псевдоним пользователя
        stmt = (
            select(LeaderboardEntry, User.username)
            .join(User, LeaderboardEntry.user_id == User.id)
            .order_by(LeaderboardEntry.monthly_points.desc())
            .limit(limit)
        )
        results = db.execute(stmt).all()

        leaderboard = []
        for index, row in enumerate(results, start=1):
            mask_name = (
                f"Игрок {row.username[:2]}***"
                if len(row.username) > 2
                else f"Пользователь #{row.LeaderboardEntry.user_id}"
            )
            leaderboard.append(
                {
                    "rank": index,
                    "display_name": mask_name,
                    "points": row.LeaderboardEntry.monthly_points,
                }
            )
        return leaderboard