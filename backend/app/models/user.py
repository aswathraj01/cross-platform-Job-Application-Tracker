from pydantic import BaseModel, EmailStr, Field


class UserSignup(BaseModel):
    """Schema for user registration."""
    email: str = Field(..., description="User email address")
    password: str = Field(..., min_length=6, description="Password (min 6 characters)")


class UserLogin(BaseModel):
    """Schema for user login."""
    email: str = Field(..., description="User email address")
    password: str = Field(..., description="User password")


class UserResponse(BaseModel):
    """Schema for auth response."""
    uid: str
    email: str
    token: str
    message: str = "Success"


class TokenData(BaseModel):
    """Schema for decoded token data."""
    uid: str
    email: str | None = None
