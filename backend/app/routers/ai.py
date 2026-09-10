from fastapi import APIRouter, HTTPException, Depends, status
from app.models.job import (
    AIExtractionRequest,
    AIExtractionResponse,
    AIChatRequest,
    AIChatResponse,
    AIAnalyzeRequest,
    AIAnalyzeResponse,
    AIAdviceRequest,
    AIAdviceResponse,
)
from app.services.ai_service import (
    extract_job_data,
    chat_with_ai,
    analyze_applications,
    get_job_advice,
)
from app.services.scraper_service import scrape_job_page
from app.middleware.auth_middleware import get_current_user

router = APIRouter(prefix="/ai", tags=["AI Extraction"])


@router.post("/extract", response_model=AIExtractionResponse)
async def extract_job_info(
    request: AIExtractionRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Extract job information from text or URL using AI.

    - If `url` is provided: scrapes the webpage first, then sends to AI.
    - If `text` is provided: sends directly to AI.
    - At least one of `text` or `url` must be provided.
    """
    if not request.text and not request.url:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Either 'text' or 'url' must be provided",
        )

    content = request.text or ""

    # If URL is provided, scrape the page content
    if request.url:
        try:
            scraped_content = scrape_job_page(request.url)
            # Combine with any provided text
            if content:
                content = f"{content}\n\n--- Scraped from URL ---\n{scraped_content}"
            else:
                content = scraped_content
        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to scrape URL: {str(e)}",
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Scraping error: {str(e)}",
            )

    # Send content to AI for extraction
    try:
        result = extract_job_data(content)

        # If URL was provided and no application_link was extracted, use the URL
        if request.url and not result.get("application_link"):
            result["application_link"] = request.url

        return AIExtractionResponse(**result)

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"AI extraction error: {str(e)}",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI processing failed: {str(e)}",
        )


@router.post("/chat", response_model=AIChatResponse)
async def ai_chat(
    request: AIChatRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Conversational AI job coach endpoint.
    Send a message and get career advice, interview tips, and more.
    Maintains conversation history for context.
    """
    try:
        history_dicts = [{"role": m.role, "content": m.content} for m in request.history]
        result = chat_with_ai(
            message=request.message,
            history=history_dicts,
            job_context=request.job_context,
        )
        return AIChatResponse(**result)

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"AI chat error: {str(e)}",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI chat failed: {str(e)}",
        )


@router.post("/analyze", response_model=AIAnalyzeResponse)
async def ai_analyze(
    request: AIAnalyzeRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Analyze overall job application statistics and provide strategic insights.
    Send a JSON summary of job applications to get personalized advice.
    """
    try:
        result = analyze_applications(request.jobs_summary)
        return AIAnalyzeResponse(**result)

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"AI analysis error: {str(e)}",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI analysis failed: {str(e)}",
        )


@router.post("/advice", response_model=AIAdviceResponse)
async def ai_advice(
    request: AIAdviceRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Get AI-powered advice and next steps for a specific job application.
    Provides personalized guidance based on company, role, status, and skills.
    """
    try:
        result = get_job_advice(
            company=request.company,
            role=request.role,
            status=request.status,
            skills=request.skills,
            notes=request.notes,
        )
        return AIAdviceResponse(**result)

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"AI advice error: {str(e)}",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI advice failed: {str(e)}",
        )
