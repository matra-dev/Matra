from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field
from beanie import Document


class AppointmentBase(BaseModel):
    doctor_name: str = Field(..., min_length=1, max_length=100)
    specialty: Optional[str] = Field(None, max_length=100)
    date: str = Field(...)
    time: str = Field(...)
    reason: Optional[str] = Field(None, max_length=500)
    notes: Optional[str] = Field(None, max_length=500)
    status: str = Field(default="scheduled", pattern="^(scheduled|completed|cancelled)$")
    created_at: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))
    user_id: str = Field(...)


class AppointmentCreate(AppointmentBase):
    pass


class AppointmentUpdate(BaseModel):
    doctor_name: Optional[str] = Field(None, min_length=1, max_length=100)
    specialty: Optional[str] = Field(None, max_length=100)
    date: Optional[str] = None
    time: Optional[str] = None
    reason: Optional[str] = Field(None, max_length=500)
    notes: Optional[str] = Field(None, max_length=500)
    status: Optional[str] = Field(None, pattern="^(scheduled|completed|cancelled)$")


class Appointment(AppointmentBase, Document):
    class Settings:
        name = "appointments"
