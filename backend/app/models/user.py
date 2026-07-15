from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, EmailStr
from beanie import Document

from app.core.security import get_password_hash, verify_password


class UserBase(BaseModel):
    email: EmailStr
    name: Optional[str] = Field(None, max_length=100)


class UserCreate(UserBase):
    password: str = Field(..., min_length=6)


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100)
    password: Optional[str] = Field(None, min_length=6)


class User(UserBase, Document):
    hashed_password: str
    created_at: int = Field(default_factory=lambda: int(datetime.now().timestamp() * 1000))
    is_active: bool = True

    class Settings:
        name = "users"

    def verify_password(self, plain_password: str) -> bool:
        return verify_password(plain_password, self.hashed_password)

    def set_password(self, password: str):
        self.hashed_password = get_password_hash(password)

    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "name": "John Doe",
                "created_at": 1705276800000,
                "is_active": True,
            }
        }
