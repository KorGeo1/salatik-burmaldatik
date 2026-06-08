import datetime
from typing import Optional
from pydantic import BaseModel


class QuestBase(BaseModel):
    title: str
    description: str
    reward_amount: int
    quest_type: str
    is_active: Optional[bool] = True
    start_date: Optional[datetime.datetime] = None
    end_date: Optional[datetime.datetime] = None


class QuestCreate(QuestBase):
    pass


class QuestResponse(QuestBase):
    id: int

    class Config:
        from_attributes = True