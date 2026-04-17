import firebase_admin
from firebase_admin import credentials, auth, firestore
from datetime import datetime
import requests
import json
from app.config import get_settings

settings = get_settings()

# Initialize Firebase Admin SDK
_firebase_app = None
_db = None


def get_firebase_app():
    """Initialize and return the Firebase app instance."""
    global _firebase_app
    if _firebase_app is None:
        try:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            _firebase_app = firebase_admin.initialize_app(cred)
        except Exception as e:
            print(f"Firebase initialization error: {e}")
            raise
    return _firebase_app


def get_firestore_client():
    """Get Firestore client instance."""
    global _db
    if _db is None:
        get_firebase_app()
        _db = firestore.client()
    return _db


# ==================== AUTH OPERATIONS ====================

def create_user(email: str, password: str) -> dict:
    """Create a new user in Firebase Auth."""
    get_firebase_app()
    try:
        user = auth.create_user(email=email, password=password)
        # Generate a custom token for the user
        custom_token = auth.create_custom_token(user.uid)
        return {
            "uid": user.uid,
            "email": user.email,
            "token": custom_token.decode("utf-8") if isinstance(custom_token, bytes) else custom_token,
        }
    except auth.EmailAlreadyExistsError:
        raise ValueError("Email already registered")
    except Exception as e:
        raise ValueError(f"Failed to create user: {str(e)}")


def verify_password(email: str, password: str) -> dict:
    """
    Verify user credentials using Firebase Auth REST API.
    Returns user data with ID token.
    """
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={settings.FIREBASE_API_KEY}"
    payload = {
        "email": email,
        "password": password,
        "returnSecureToken": True,
    }
    response = requests.post(url, json=payload)

    if response.status_code != 200:
        error_data = response.json()
        error_message = error_data.get("error", {}).get("message", "Authentication failed")
        raise ValueError(f"Login failed: {error_message}")

    data = response.json()
    return {
        "uid": data["localId"],
        "email": data["email"],
        "token": data["idToken"],
    }


def verify_token(token: str) -> dict:
    """Verify a Firebase ID token and return decoded claims."""
    get_firebase_app()
    try:
        decoded = auth.verify_id_token(token)
        return {
            "uid": decoded["uid"],
            "email": decoded.get("email"),
        }
    except auth.InvalidIdTokenError:
        raise ValueError("Invalid token")
    except auth.ExpiredIdTokenError:
        raise ValueError("Token expired")
    except Exception as e:
        raise ValueError(f"Token verification failed: {str(e)}")


# ==================== JOB OPERATIONS ====================

def create_job(user_id: str, job_data: dict) -> dict:
    """Create a new job entry in Firestore."""
    db = get_firestore_client()
    now = datetime.utcnow().isoformat()
    job_data["user_id"] = user_id
    job_data["created_at"] = now
    job_data["updated_at"] = now

    doc_ref = db.collection("users").document(user_id).collection("jobs").document()
    doc_ref.set(job_data)

    job_data["id"] = doc_ref.id
    return job_data


def get_jobs(user_id: str, status: str = None, company: str = None) -> list:
    """Get all jobs for a user with optional filtering."""
    db = get_firestore_client()
    query = db.collection("users").document(user_id).collection("jobs")

    if status:
        query = query.where("status", "==", status)

    docs = query.order_by("created_at", direction=firestore.Query.DESCENDING).stream()

    jobs = []
    for doc in docs:
        job = doc.to_dict()
        job["id"] = doc.id
        # Apply company filter client-side (Firestore doesn't support case-insensitive search)
        if company:
            if company.lower() not in job.get("company", "").lower():
                continue
        jobs.append(job)

    return jobs


def get_job(user_id: str, job_id: str) -> dict | None:
    """Get a single job by ID."""
    db = get_firestore_client()
    doc = db.collection("users").document(user_id).collection("jobs").document(job_id).get()

    if not doc.exists:
        return None

    job = doc.to_dict()
    job["id"] = doc.id
    return job


def update_job(user_id: str, job_id: str, job_data: dict) -> dict | None:
    """Update a job entry."""
    db = get_firestore_client()
    doc_ref = db.collection("users").document(user_id).collection("jobs").document(job_id)

    doc = doc_ref.get()
    if not doc.exists:
        return None

    job_data["updated_at"] = datetime.utcnow().isoformat()
    # Remove None values
    update_data = {k: v for k, v in job_data.items() if v is not None}
    doc_ref.update(update_data)

    updated_doc = doc_ref.get()
    job = updated_doc.to_dict()
    job["id"] = doc_ref.id
    return job


def delete_job(user_id: str, job_id: str) -> bool:
    """Delete a job entry."""
    db = get_firestore_client()
    doc_ref = db.collection("users").document(user_id).collection("jobs").document(job_id)

    doc = doc_ref.get()
    if not doc.exists:
        return False

    doc_ref.delete()
    return True
