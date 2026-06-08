from pydantic import BaseModel


class RewardBase(BaseModel):
    title: str
    description: str
    cost: int
    stock: int


class RewardCreate(RewardBase):
    pass


class RewardResponse(RewardBase):
    id: int

    class Config:
        from_attributes = True