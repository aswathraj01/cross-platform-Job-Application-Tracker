from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import get_settings
from app.routers import auth, jobs, ai

settings = get_settings()

# Create FastAPI application
app = FastAPI(
    title="Job Application Tracker API",
    description="Backend API for the Cross-Platform Job Application Tracker with AI-powered job extraction",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api")
app.include_router(jobs.router, prefix="/api")
app.include_router(ai.router, prefix="/api")


@app.get("/", tags=["Health"])
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "Job Application Tracker API",
        "version": "1.0.0",
    }


@app.get("/api", tags=["Health"])
async def api_info():
    """API information endpoint."""
    return {
        "message": "Job Application Tracker API",
        "version": "1.0.0",
        "endpoints": {
            "auth": "/api/auth",
            "jobs": "/api/jobs",
            "ai": "/api/ai",
            "docs": "/docs",
        },
    }
