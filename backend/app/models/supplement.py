from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field
from beanie import Document


class SupplementBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    dosage_amount: float = Field(..., gt=0)
    dosage_unit: str = Field(..., pattern="^(mg|mcg|IU|g|ml)$")
    frequency: int = Field(..., ge=1, le=10)
    stock_count: int = Field(..., ge=0)
    time_slots: List[str] = Field(default_factory=list)
    start_date: str = Field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d"))
    created_at: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))
    user_id: str = Field(...)


class SupplementCreate(SupplementBase):
    pass


class SupplementUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    dosage_amount: Optional[float] = Field(None, gt=0)
    dosage_unit: Optional[str] = Field(None, pattern="^(mg|mcg|IU|g|ml)$")
    frequency: Optional[int] = Field(None, ge=1, le=10)
    stock_count: Optional[int] = Field(None, ge=0)
    time_slots: Optional[List[str]] = None


class Supplement(SupplementBase, Document):
    class Settings:
        name = "supplements"

    class Config:
        json_schema_extra = {
            "example": {
                "name": "Vitamin D3",
                "dosage_amount": 5000,
                "dosage_unit": "IU",
                "frequency": 1,
                "stock_count": 60,
                "time_slots": ["Morning"],
                "start_date": "2024-01-15",
                "created_at": 1705276800000,
                "user_id": "user_id_here",
            }
        }
