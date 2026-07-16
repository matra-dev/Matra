from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field
from beanie import Document


class WaterLogBase(BaseModel):
    amount_ml: int = Field(..., ge=1, le=5000, description="Water amount in milliliters")
    user_id: str = Field(...)
    date: str = Field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d"))
    timestamp: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))
    note: Optional[str] = Field(default=None, max_length=200)


class WaterLogCreate(BaseModel):
    amount_ml: int = Field(..., ge=1, le=5000, description="Water amount in milliliters")
    date: str = Field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d"))
    timestamp: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))
    note: Optional[str] = Field(default=None, max_length=200)


class WaterLog(WaterLogBase, Document):
    class Settings:
        name = "water_logs"
