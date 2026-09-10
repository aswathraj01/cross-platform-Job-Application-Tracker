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
    source: Optional[str] = Field(default="manual", description="Source: manual, ai_extract, extension")
    domain: Optional[str] = Field(None, max_length=200, description="Domain of the job posting")


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
    source: Optional[str] = None
    domain: Optional[str] = Field(None, max_length=200)


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
    source: Optional[str] = "manual"
    domain: Optional[str] = None


class AIExtractionRequest(BaseModel):
    """Schema for AI extraction request."""
    text: Optional[str] = Field(None, description="Job description text")
    url: Optional[str] = Field(None, description="URL to job posting")
    html: Optional[str] = Field(None, description="Raw HTML from extension content script")


class AIExtractionResponse(BaseModel):
    """Schema for AI extraction response."""
    company: Optional[str] = None
    role: Optional[str] = None
    location: Optional[str] = None
    skills: list[str] = []
    application_link: Optional[str] = None
    notes: Optional[str] = None
    domain: Optional[str] = None


class ExtensionScrapeRequest(BaseModel):
    """Schema for extension scrape+extract request."""
    url: str = Field(..., description="Current page URL")
    html: Optional[str] = Field(None, description="Page HTML from extension")
    title: Optional[str] = Field(None, description="Page title")


class ExtensionCheckRequest(BaseModel):
    """Schema for checking if a domain was already applied to."""
    domain: str = Field(..., description="Domain to check")
    url: Optional[str] = Field(None, description="Full URL for more precise check")


class ExtensionCheckResponse(BaseModel):
    """Schema for domain check response."""
    applied: bool
    jobs: list[JobResponse] = []


class ExtensionCaptureRequest(BaseModel):
    """Schema for capturing a job via extension."""
    company: str = Field(..., min_length=1, max_length=200)
    role: str = Field(..., min_length=1, max_length=200)
    location: Optional[str] = None
    status: JobStatus = Field(default=JobStatus.APPLIED)
    applied_date: Optional[str] = None
    application_link: Optional[str] = None
    notes: Optional[str] = None
    skills: list[str] = Field(default_factory=list)
    domain: Optional[str] = None


class AIChatMessage(BaseModel):
    """A single message in an AI chat conversation."""
    role: str = Field(..., description="'user' or 'assistant'")
    content: str = Field(..., description="Message content")


class AIChatRequest(BaseModel):
    """Schema for AI chat request."""
    message: str = Field(..., min_length=1, max_length=2000, description="User message")
    history: list[AIChatMessage] = Field(default_factory=list, description="Conversation history")
    job_context: Optional[str] = Field(None, description="Optional job context (company, role, etc.)")


class AIChatResponse(BaseModel):
    """Schema for AI chat response."""
    reply: str
    suggestions: list[str] = []


class AIAnalyzeRequest(BaseModel):
    """Schema for AI job application analysis request."""
    jobs_summary: str = Field(..., description="JSON summary of user's job applications")


class AIAnalyzeResponse(BaseModel):
    """Schema for AI analysis response."""
    insights: str
    tips: list[str] = []
    strengths: list[str] = []
    areas_to_improve: list[str] = []


class AIAdviceRequest(BaseModel):
    """Schema for AI advice on a specific job."""
    company: str
    role: str
    status: str
    skills: list[str] = []
    notes: Optional[str] = None


class AIAdviceResponse(BaseModel):
    """Schema for AI job advice response."""
    advice: str
    next_steps: list[str] = []
    interview_tips: list[str] = []

