from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field
from beanie import Document


class MeasurementBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    unit: str = Field(..., min_length=1, max_length=20)
    value: float = Field(...)
    notes: Optional[str] = Field(None, max_length=500)
    measured_at: str = Field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d"))
    created_at: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))
    user_id: str = Field(...)


class MeasurementCreate(MeasurementBase):
    pass


class MeasurementUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    unit: Optional[str] = Field(None, min_length=1, max_length=20)
    value: Optional[float] = None
    notes: Optional[str] = Field(None, max_length=500)
    measured_at: Optional[str] = None


class Measurement(MeasurementBase, Document):
    class Settings:
        name = "measurements"
