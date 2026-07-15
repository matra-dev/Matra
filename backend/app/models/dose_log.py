from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field
from beanie import Document


class DoseLogBase(BaseModel):
    supplement_id: str = Field(...)
    user_id: str = Field(...)
    date: str = Field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d"))
    timestamp: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))


class DoseLogCreate(DoseLogBase):
    pass


class DoseLog(DoseLogBase, Document):
    class Settings:
        name = "dose_logs"
