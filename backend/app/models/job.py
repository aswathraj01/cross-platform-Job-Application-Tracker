from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


class JobStatus(str, Enum):
    """Possible job application statuses."""
    NOT_APPLIED = "Not Applied"
    APPLIED = "Applied"
    INTERVIEW = "Interview"
    REJECTED = "Rejected"
    OFFER = "Offer"


class JobCreate(BaseModel):
    """Schema for creating a new job entry."""
    company: str = Field(..., min_length=1, max_length=200, description="Company name")
    role: str = Field(..., min_length=1, max_length=200, description="Job role/title")
    location: Optional[str] = Field(None, max_length=200, description="Job location")
    status: JobStatus = Field(default=JobStatus.NOT_APPLIED, description="Application status")
    applied_date: Optional[str] = Field(None, description="Date applied (ISO format)")
    application_link: Optional[str] = Field(None, max_length=500, description="Link to job posting")
    notes: Optional[str] = Field(None, max_length=2000, description="Additional notes")
    skills: list[str] = Field(default_factory=list, description="Required skills")


class JobUpdate(BaseModel):
    """Schema for updating a job entry. All fields are optional."""
    company: Optional[str] = Field(None, min_length=1, max_length=200)
    role: Optional[str] = Field(None, min_length=1, max_length=200)
    location: Optional[str] = Field(None, max_length=200)
    status: Optional[JobStatus] = None
    applied_date: Optional[str] = None
    application_link: Optional[str] = Field(None, max_length=500)
    notes: Optional[str] = Field(None, max_length=2000)
    skills: Optional[list[str]] = None


class JobResponse(BaseModel):
    """Schema for job response."""
    id: str
    company: str
    role: str
    location: Optional[str] = None
    status: str
    applied_date: Optional[str] = None
    application_link: Optional[str] = None
    notes: Optional[str] = None
    skills: list[str] = []
    user_id: str
    created_at: str
    updated_at: Optional[str] = None


class AIExtractionRequest(BaseModel):
    """Schema for AI extraction request."""
    text: Optional[str] = Field(None, description="Job description text")
    url: Optional[str] = Field(None, description="URL to job posting")


class AIExtractionResponse(BaseModel):
    """Schema for AI extraction response."""
    company: Optional[str] = None
    role: Optional[str] = None
    location: Optional[str] = None
    skills: list[str] = []
    application_link: Optional[str] = None
    notes: Optional[str] = None
