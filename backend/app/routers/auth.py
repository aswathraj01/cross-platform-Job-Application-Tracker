from fastapi import APIRouter, HTTPException, status
from app.models.user import UserSignup, UserLogin, UserResponse, TokenRefreshRequest
from app.services.firebase_service import create_user, verify_password, refresh_id_token

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/signup", response_model=UserResponse)
async def signup(user: UserSignup):
    """Register a new user with email and password."""
    try:
        result = create_user(email=user.email, password=user.password)
        return UserResponse(
            uid=result["uid"],
            email=result["email"],
            token=result["token"],
            message="Account created successfully",
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Registration failed: {str(e)}",
        )


@router.post("/login", response_model=UserResponse)
async def login(user: UserLogin):
    """Login with email and password. Returns Firebase ID token."""
    try:
        result = verify_password(email=user.email, password=user.password)
        return UserResponse(
            uid=result["uid"],
            email=result["email"],
            token=result["token"],
            message="Login successful",
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Login failed: {str(e)}",
        )


@router.post("/refresh", response_model=UserResponse)
async def refresh_token(body: TokenRefreshRequest):
    """Exchange a Firebase refresh token for a new ID token (no password needed)."""
    try:
        result = refresh_id_token(body.refresh_token)
        return UserResponse(
            uid=result["uid"],
            email="",          # caller already has this stored
            token=result["token"],
            refresh_token=result["refresh_token"],
            message="Token refreshed",
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Token refresh failed: {str(e)}",
        )
