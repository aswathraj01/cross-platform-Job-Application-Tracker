from fastapi import APIRouter, HTTPException, Depends, status
from urllib.parse import urlparse
from app.models.job import (
    ExtensionScrapeRequest,
    ExtensionCheckRequest,
    ExtensionCheckResponse,
    ExtensionCaptureRequest,
    AIExtractionResponse,
    JobResponse,
)
from app.services.firebase_service import create_job, check_domain_applied
from app.services.scraper_service import extract_from_html
from app.services.ai_service import extract_job_data
from app.middleware.auth_middleware import get_current_user
from datetime import datetime

router = APIRouter(prefix="/extension", tags=["Chrome Extension"])


def _extract_domain(url: str) -> str | None:
    """Extract clean hostname from URL."""
    if not url:
        return None
    try:
        parsed = urlparse(url)
        return parsed.netloc.lower().lstrip("www.") if parsed.netloc else None
    except Exception:
        return None


@router.post("/scrape", response_model=AIExtractionResponse)
async def extension_scrape(
    request: ExtensionScrapeRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Accept page HTML + URL from the Chrome extension, extract text, and
    return AI-parsed job details (company, role, location, skills, etc.)
    """
    try:
        # Use the HTML from the extension (real browser session — avoids bot detection)
        if request.html:
            content = extract_from_html(request.html, request.url)
        else:
            # Fallback: use title + URL as minimal context
            content = f"Page URL: {request.url}\nPage Title: {request.title or ''}"

        result = extract_job_data(content)

        # Always set application_link to the current page URL
        if not result.get("application_link"):
            result["application_link"] = request.url

        # Extract and attach domain
        result["domain"] = _extract_domain(request.url)

        return AIExtractionResponse(**result)

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Extraction error: {str(e)}",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Scrape failed: {str(e)}",
        )


@router.post("/check", response_model=ExtensionCheckResponse)
async def extension_check(
    request: ExtensionCheckRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Check if the current user has previously applied to any jobs
    from the given domain. Used by the extension to show 'Already Applied' badges.
    """
    try:
        domain = request.domain or _extract_domain(request.url or "")
        if not domain:
            return ExtensionCheckResponse(applied=False, jobs=[])

        matches = check_domain_applied(current_user["uid"], domain)
        job_responses = [JobResponse(**j) for j in matches]
        return ExtensionCheckResponse(
            applied=len(job_responses) > 0,
            jobs=job_responses,
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Domain check failed: {str(e)}",
        )


@router.post("/capture", response_model=JobResponse, status_code=status.HTTP_201_CREATED)
async def extension_capture(
    request: ExtensionCaptureRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Create a new job entry captured via the Chrome extension.
    Sets source='extension' automatically.
    """
    try:
        job_data = request.model_dump()
        # Ensure status is serialized correctly
        job_data["status"] = (
            job_data["status"].value
            if hasattr(job_data["status"], "value")
            else job_data["status"]
        )
        job_data["source"] = "extension"
        if not job_data.get("applied_date") and job_data["status"] == "Applied":
            job_data["applied_date"] = datetime.utcnow().strftime("%Y-%m-%d")

        result = create_job(user_id=current_user["uid"], job_data=job_data)
        return JobResponse(**result)

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Capture failed: {str(e)}",
        )
