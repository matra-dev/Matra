from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, EmailStr
from beanie import Document

from app.core.security import get_password_hash, verify_password


class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    phone: Optional[str] = Field(None, max_length=20)
    name: Optional[str] = Field(None, max_length=100)
    country_code: Optional[str] = Field(None, max_length=5)


class UserCreate(UserBase):
    password: Optional[str] = Field(None, min_length=6)


class UserLogin(BaseModel):
    email: Optional[EmailStr] = None
    phone: Optional[str] = Field(None, max_length=20)
    password: Optional[str] = None


class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100)
    password: Optional[str] = Field(None, min_length=6)


class User(UserBase, Document):
    hashed_password: Optional[str] = None
    created_at: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))
    is_active: bool = True

    class Settings:
        name = "users"

    def verify_password(self, plain_password: str) -> bool:
        if not self.hashed_password:
            return False
        return verify_password(plain_password, self.hashed_password)

    def set_password(self, password: str):
        self.hashed_password = get_password_hash(password)

    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "phone": "+1234567890",
                "name": "John Doe",
                "created_at": 1705276800000,
                "is_active": True,
            }
        }
