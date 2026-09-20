from pydantic_settings import BaseSettings
from functools import lru_cache
import os
from dotenv import load_dotenv

load_dotenv()


class Settings(BaseSettings):
    """Application configuration loaded from environment variables."""

    # LLM Configuration
    LLM_PROVIDER: str = "gemini"
    OPENAI_API_KEY: str = ""
    LLM_BASE_URL: str = "https://api.openai.com/v1"
    LLM_MODEL: str = "gemini-1.5-flash"
    GEMINI_API_KEY: str = ""

    # Firebase Configuration
    FIREBASE_CREDENTIALS_PATH: str = "serviceAccountKey.json"
    FIREBASE_CREDENTIALS_BASE64: str = ""  # Base64-encoded service account JSON (for production)
    FIREBASE_API_KEY: str = ""

    # Server Configuration
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # CORS — includes localhost dev + Firebase Hosting + any deployed frontend
    CORS_ORIGINS: list[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5000",
        "http://localhost:8000",
        # Firebase Hosting
        "https://job-application-tracker-9f4d8.web.app",
        "https://job-application-tracker-9f4d8.firebaseapp.com",
        # Render.com backend itself (for Swagger UI)
        "https://job-tracker-api-i9hd.onrender.com",
        # Wildcard for development convenience
        "*",
    ]

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
