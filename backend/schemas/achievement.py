from pydantic import BaseModel


class AchievementResponse(BaseModel):
    id: int
    title: str
    description: str
    icon: str

    class Config:
        from_attributes = True