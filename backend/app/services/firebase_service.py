import base64
import firebase_admin
from firebase_admin import credentials, auth, firestore
from datetime import datetime
import requests
import json
from urllib.parse import urlparse
from app.config import get_settings

settings = get_settings()

# Initialize Firebase Admin SDK
_firebase_app = None
_db = None


def get_firebase_app():
    """Initialize and return the Firebase app instance.

    Credential resolution order:
    1. FIREBASE_CREDENTIALS_BASE64 env var — base64-encoded JSON of the service account
       key. This is the recommended approach for production deployments (e.g. Render.com)
       where the serviceAccountKey.json file cannot be committed to the repository.
    2. FIREBASE_CREDENTIALS_PATH — path to the serviceAccountKey.json file, used for
       local development (defaults to 'serviceAccountKey.json').
    """
    global _firebase_app
    if _firebase_app is None:
        try:
            if settings.FIREBASE_CREDENTIALS_BASE64:
                # Production: decode the base64 env var into a dict and use it directly.
                # Strip whitespace first — some platforms (e.g. Render) wrap long env vars.
                clean_b64 = settings.FIREBASE_CREDENTIALS_BASE64.strip()
                json_bytes = base64.b64decode(clean_b64)
                service_account_info = json.loads(json_bytes.strip())
                # Ensure the private_key has real newlines (not escaped \n sequences).
                # Some env var UIs store \n as a literal backslash-n.
                if 'private_key' in service_account_info:
                    key = service_account_info['private_key']
                    key = key.replace('\\n', '\n')
                    key = key.strip()
                    if not key.endswith('\n'):
                        key += '\n'
                    service_account_info['private_key'] = key
                cred = credentials.Certificate(service_account_info)
                print("Firebase initialised from FIREBASE_CREDENTIALS_BASE64 env var.")
            else:
                # Local development: load from the JSON file
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
                print(f"Firebase initialised from file: {settings.FIREBASE_CREDENTIALS_PATH}")
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
    """Create a new user using Firebase Auth REST API."""
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={settings.FIREBASE_API_KEY}"
    payload = {
        "email": email,
        "password": password,
        "returnSecureToken": True,
    }
    response = requests.post(url, json=payload)

    if response.status_code != 200:
        error_data = response.json()
        error_message = error_data.get("error", {}).get("message", "Registration failed")
        if error_message == "EMAIL_EXISTS":
            raise ValueError("Email already registered")
        raise ValueError(f"Failed to create user: {error_message}")

    data = response.json()
    return {
        "uid": data["localId"],
        "email": data.get("email", email),
        "token": data["idToken"],
        "refresh_token": data.get("refreshToken", ""),
    }


def verify_password(email: str, password: str) -> dict:
    """
    Verify user credentials using Firebase Auth REST API.
    Returns user data with ID token and refresh token.
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
        "refresh_token": data.get("refreshToken", ""),
    }


def refresh_id_token(refresh_token: str) -> dict:
    """
    Exchange a Firebase refresh token for a new ID token.
    Returns new token data.
    """
    url = f"https://securetoken.googleapis.com/v1/token?key={settings.FIREBASE_API_KEY}"
    payload = {
        "grant_type": "refresh_token",
        "refresh_token": refresh_token,
    }
    response = requests.post(url, json=payload)

    if response.status_code != 200:
        error_data = response.json()
        error_message = error_data.get("error", {}).get("message", "Token refresh failed")
        raise ValueError(f"Token refresh failed: {error_message}")

    data = response.json()
    return {
        "token": data["id_token"],
        "refresh_token": data["refresh_token"],
        "uid": data["user_id"],
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

def _extract_domain(url: str) -> str | None:
    """Extract the hostname domain from a URL."""
    if not url:
        return None
    try:
        parsed = urlparse(url)
        return parsed.netloc.lower().lstrip("www.") if parsed.netloc else None
    except Exception:
        return None


def create_job(user_id: str, job_data: dict) -> dict:
    """Create a new job entry in Firestore."""
    db = get_firestore_client()
    now = datetime.utcnow().isoformat()
    job_data["user_id"] = user_id
    job_data["created_at"] = now
    job_data["updated_at"] = now

    # Auto-extract domain from application_link if not already set
    if not job_data.get("domain") and job_data.get("application_link"):
        job_data["domain"] = _extract_domain(job_data["application_link"])

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


def check_domain_applied(user_id: str, domain: str) -> list:
    """
    Check if a user has any job entries matching a given domain.
    Returns a list of matching job dicts (empty if none).
    """
    db = get_firestore_client()
    query = db.collection("users").document(user_id).collection("jobs")
    docs = query.stream()

    matches = []
    for doc in docs:
        job = doc.to_dict()
        job["id"] = doc.id
        job_domain = job.get("domain") or _extract_domain(job.get("application_link", "") or "")
        if job_domain and domain and job_domain.lower() == domain.lower():
            matches.append(job)

    return matches
