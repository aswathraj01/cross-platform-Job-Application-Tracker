# 🚀 Cross-Platform Job Application Tracker

> **AI-powered job application tracking** — built with Flutter, FastAPI, and Firebase.

Track your job applications across mobile and web with smart AI extraction that auto-fills job data from descriptions or URLs.

![Flutter](https://img.shields.io/badge/Flutter-3.32-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)
![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

### 📋 Job Tracking
- **Full CRUD** — Create, read, update, and delete job applications
- **Rich Fields** — Company, role, location, status, applied date, link, notes, skills
- **Status Tracking** — Not Applied → Applied → Interview → Rejected / Offer
- **Search & Filter** — Find jobs by company, role, or filter by status

### 🤖 AI-Powered Extraction
- **Paste text** — Copy a job description, AI extracts structured data
- **Enter URL** — Provide a link, the backend scrapes and extracts automatically
- **Smart Preview** — Review extracted data before saving
- **"Have you applied?"** — Quick confirmation sets the right status

### 📊 Analytics Dashboard
- **Total Applications** count
- **Status Breakdown** — Visual pie chart
- **Interview & Offer Rates** — Track your success metrics
- **Real-time Updates** — Pull to refresh

### 🔐 Authentication
- Email/password signup & login
- Persistent sessions (auto-login)
- Firebase Auth with secure token verification

### 📱 Cross-Platform
- **Android** — Native Flutter app
- **Web PWA** — Installable Progressive Web App
- **Responsive** — Works on mobile and desktop viewports

---

## 🏗 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.32 (Dart) |
| **Backend** | FastAPI (Python 3.11) |
| **Database** | Firebase Firestore |
| **Auth** | Firebase Authentication |
| **AI** | OpenAI API (modular — supports local LLaMA) |
| **Scraping** | BeautifulSoup4 |
| **State Mgmt** | Provider |

---

## 📁 Project Structure

```
├── backend/                    # FastAPI Backend
│   ├── app/
│   │   ├── main.py             # App entry, CORS, routers
│   │   ├── config.py           # Environment config
│   │   ├── models/             # Pydantic schemas
│   │   ├── routers/            # API endpoints
│   │   │   ├── auth.py         # /auth (signup, login)
│   │   │   ├── jobs.py         # /jobs (CRUD)
│   │   │   └── ai.py           # /ai/extract
│   │   ├── services/           # Business logic
│   │   │   ├── firebase_service.py
│   │   │   ├── ai_service.py
│   │   │   └── scraper_service.py
│   │   └── middleware/         # Auth middleware
│   ├── requirements.txt
│   └── .env.example
│
├── frontend/                   # Flutter App
│   ├── lib/
│   │   ├── main.dart           # App entry, theme, routing
│   │   ├── config/             # API configuration
│   │   ├── models/             # Data models
│   │   ├── services/           # API service calls
│   │   ├── providers/          # State management
│   │   ├── screens/            # UI screens
│   │   └── widgets/            # Reusable components
│   └── web/                    # PWA config
│
├── .gitignore
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter** 3.x ([Install](https://docs.flutter.dev/get-started/install))
- **Python** 3.11+ ([Install](https://python.org/downloads))
- **Firebase** project with Firestore & Auth enabled
- **OpenAI API key** (or local LLaMA via Ollama)

---

### 1. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing)
3. Enable **Authentication** → Email/Password provider
4. Enable **Cloud Firestore** (start in test mode)
5. Go to **Project Settings** → **Service Accounts** → **Generate new private key**
6. Save the downloaded file as `backend/serviceAccountKey.json`
7. Copy your **Web API Key** from Project Settings → General

---

### 2. Backend Setup

```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv

# Activate it
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your API keys:
#   OPENAI_API_KEY=sk-...
#   FIREBASE_API_KEY=AIza...
#   FIREBASE_CREDENTIALS_PATH=serviceAccountKey.json

# Run the server
uvicorn app.main:app --reload --port 8000
```

The API will be available at `http://localhost:8000`
- Swagger docs: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

---

### 3. Frontend Setup

```bash
# Navigate to frontend
cd frontend

# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Run on Android (with device/emulator connected)
flutter run -d android

# Build for web
flutter build web
```

> **Note:** Update `lib/config/api_config.dart` if your backend runs on a different URL.

---

### 4. Using Local LLaMA (Optional)

If you want to use a local LLM instead of OpenAI:

1. Install [Ollama](https://ollama.ai)
2. Pull a model: `ollama pull llama3`
3. Update `.env`:
```env
LLM_PROVIDER=local
LLM_BASE_URL=http://localhost:11434/v1
LLM_MODEL=llama3
OPENAI_API_KEY=not-needed
```

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/auth/signup` | Register new user |
| `POST` | `/api/auth/login` | Login and get token |
| `GET` | `/api/jobs` | List all jobs (with filters) |
| `POST` | `/api/jobs/` | Create new job |
| `GET` | `/api/jobs/{id}` | Get job details |
| `PUT` | `/api/jobs/{id}` | Update job |
| `DELETE` | `/api/jobs/{id}` | Delete job |
| `POST` | `/api/ai/extract` | AI job extraction |

All `/jobs` and `/ai` endpoints require `Authorization: Bearer <token>` header.

---

## 🎨 UI Screens

| Screen | Description |
|--------|-------------|
| **Login** | Email/password with modern dark glass design |
| **Signup** | Registration with password confirmation |
| **Dashboard** | Analytics cards, pie chart, job list, search & filter |
| **Add Job** | Full form with status dropdown, date picker, skills chips |
| **Job Details** | View details, update status, delete, open link |
| **AI Extract** | Paste text or URL, preview results, confirm status |

---

## 🔒 Security

- Firebase ID token verification on all protected endpoints
- Pydantic input validation on backend
- Form validation on frontend
- Jobs scoped per user (Firestore subcollections)
- Environment variables for all secrets
- `.gitignore` excludes `.env` and credentials

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) — Cross-platform UI toolkit
- [FastAPI](https://fastapi.tiangolo.com) — Modern Python web framework
- [Firebase](https://firebase.google.com) — Backend-as-a-Service
- [OpenAI](https://openai.com) — AI-powered extraction
- [fl_chart](https://pub.dev/packages/fl_chart) — Beautiful charts for Flutter