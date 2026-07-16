from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field
from beanie import Document


class CalorieLogBase(BaseModel):
    calories: int = Field(..., ge=1, le=10000, description="Calories consumed")
    meal_type: str = Field(default="snack", pattern="^(breakfast|lunch|dinner|snack)$")
    user_id: str = Field(...)
    date: str = Field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d"))
    timestamp: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))
    note: Optional[str] = Field(default=None, max_length=200)


class CalorieLogCreate(BaseModel):
    calories: int = Field(..., ge=1, le=10000, description="Calories consumed")
    meal_type: str = Field(default="snack", pattern="^(breakfast|lunch|dinner|snack)$")
    date: str = Field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d"))
    timestamp: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))
    note: Optional[str] = Field(default=None, max_length=200)


class CalorieLog(CalorieLogBase, Document):
    class Settings:
        name = "calorie_logs"
