from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional, List
from datetime import datetime


class UserBase(BaseModel):
    username: str
    email: EmailStr


class UserCreate(UserBase):
    password: str
    
    @validator('password')
    def password_strength(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        return v


class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = None


class UserInDB(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    
    class Config:
        orm_mode = True


class User(UserInDB):
    pass


class TokenData(BaseModel):
    username: Optional[str] = None


class Token(BaseModel):
    access_token: str
    token_type: str


class ProfileBase(BaseModel):
    full_name: Optional[str] = None
    bio: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    country: Optional[str] = None
    postal_code: Optional[str] = None


class ProfileCreate(ProfileBase):
    pass


class ProfileUpdate(ProfileBase):
    pass


class ProfileInDB(ProfileBase):
    id: int
    user_id: int
    created_at: datetime
    
    class Config:
        orm_mode = True


class Profile(ProfileInDB):
    pass


class LegalQueryBase(BaseModel):
    query: str
    category: Optional[str] = None


class LegalQueryCreate(LegalQueryBase):
    pass


class LegalQueryUpdate(BaseModel):
    query: Optional[str] = None
    category: Optional[str] = None
    is_saved: Optional[bool] = None


class LegalQueryInDB(LegalQueryBase):
    id: int
    user_id: int
    response: Optional[str] = None
    is_saved: bool
    created_at: datetime
    
    class Config:
        orm_mode = True


class LegalQuery(LegalQueryInDB):
    pass