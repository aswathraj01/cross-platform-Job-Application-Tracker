from fastapi import APIRouter, HTTPException, Depends, Query, status
from app.models.job import JobCreate, JobUpdate, JobResponse
from app.services.firebase_service import (
    create_job,
    get_jobs,
    get_job,
    update_job,
    delete_job,
)
from app.middleware.auth_middleware import get_current_user

router = APIRouter(prefix="/jobs", tags=["Jobs"])


@router.post("", response_model=JobResponse, status_code=status.HTTP_201_CREATED)
async def create_new_job(
    job: JobCreate,
    current_user: dict = Depends(get_current_user),
):
    """Create a new job entry for the authenticated user."""
    try:
        job_data = job.model_dump()
        # Convert enum to string value
        job_data["status"] = job_data["status"].value if hasattr(job_data["status"], "value") else job_data["status"]
        result = create_job(user_id=current_user["uid"], job_data=job_data)
        return JobResponse(**result)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create job: {str(e)}",
        )


@router.get("", response_model=list[JobResponse])
async def list_jobs(
    status_filter: str | None = Query(None, alias="status", description="Filter by status"),
    company: str | None = Query(None, description="Search by company name"),
    current_user: dict = Depends(get_current_user),
):
    """List all jobs for the authenticated user with optional filtering."""
    try:
        jobs = get_jobs(
            user_id=current_user["uid"],
            status=status_filter,
            company=company,
        )
        return [JobResponse(**job) for job in jobs]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch jobs: {str(e)}",
        )


@router.get("/{job_id}", response_model=JobResponse)
async def get_single_job(
    job_id: str,
    current_user: dict = Depends(get_current_user),
):
    """Get a single job by ID."""
    job = get_job(user_id=current_user["uid"], job_id=job_id)
    if not job:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Job not found",
        )
    return JobResponse(**job)


@router.put("/{job_id}", response_model=JobResponse)
async def update_existing_job(
    job_id: str,
    job: JobUpdate,
    current_user: dict = Depends(get_current_user),
):
    """Update a job entry."""
    try:
        job_data = job.model_dump(exclude_unset=True)
        # Convert enum to string value if present
        if "status" in job_data and job_data["status"] is not None:
            job_data["status"] = job_data["status"].value if hasattr(job_data["status"], "value") else job_data["status"]

        result = update_job(
            user_id=current_user["uid"],
            job_id=job_id,
            job_data=job_data,
        )
        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Job not found",
            )
        return JobResponse(**result)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update job: {str(e)}",
        )


@router.delete("/{job_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_existing_job(
    job_id: str,
    current_user: dict = Depends(get_current_user),
):
    """Delete a job entry."""
    success = delete_job(user_id=current_user["uid"], job_id=job_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Job not found",
        )
    return None
