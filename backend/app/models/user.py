from pydantic import BaseModel, Field
from typing import Optional


class UserSignup(BaseModel):
    """Schema for user registration."""
    email: str = Field(..., description="User email address")
    password: str = Field(..., min_length=6, description="Password (min 6 characters)")


class UserLogin(BaseModel):
    """Schema for user login."""
    email: str = Field(..., description="User email address")
    password: str = Field(..., description="User password")


class UserResponse(BaseModel):
    """Schema for auth response — includes refresh_token so the client can silently renew expired ID tokens."""
    uid: str
    email: str
    token: str
    refresh_token: Optional[str] = ""
    message: str = "Success"


class TokenRefreshRequest(BaseModel):
    """Schema for token refresh request."""
    refresh_token: str = Field(..., description="Firebase refresh token")


class TokenData(BaseModel):
    """Schema for decoded token data."""
    uid: str
    email: str | None = None
