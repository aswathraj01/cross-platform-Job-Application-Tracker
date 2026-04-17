from fastapi import APIRouter, HTTPException, Depends, status
from app.models.job import AIExtractionRequest, AIExtractionResponse
from app.services.ai_service import extract_job_data
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
