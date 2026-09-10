# 🚀 Cross-Platform Job Application Tracker

> **AI-powered job application tracking** — built with Flutter, FastAPI, Firebase, and Gemini AI.

Track your job applications across mobile and web with smart AI extraction, an AI Job Coach chatbot, and automated analytics.

![Flutter](https://img.shields.io/badge/Flutter-3.32-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)
![Python](https://img.shields.io/badge/Python-3.14-3776AB?logo=python)
![Render](https://img.shields.io/badge/Backend-Render.com-46E3B7?logo=render)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🌐 Live Demo

| Service | URL |
|---------|-----|
| **🖥️ Web App (PWA)** | **[https://job-application-tracker-9f4d8.web.app](https://job-application-tracker-9f4d8.web.app)** |
| **⚙️ Backend API** | **[https://job-tracker-api-i9hd.onrender.com](https://job-tracker-api-i9hd.onrender.com)** |
| **📖 API Docs (Swagger)** | **[https://job-tracker-api-i9hd.onrender.com/docs](https://job-tracker-api-i9hd.onrender.com/docs)** |

> ⚠️ **Note**: The backend runs on Render.com free tier. First request after idle may take ~30 seconds to warm up (cold start). Subsequent requests are fast.

### 🔑 Test Account
```
Email:    testing@gmail.com
Password: 1234567890
```

---

## ✨ Features

### 📋 Job Tracking
- **Full CRUD** — Create, read, update, and delete job applications
- **Rich Fields** — Company, role, location, status, applied date, link, notes, skills
- **Status Tracking** — Not Applied → Applied → Interview → Rejected / Offer
- **Search & Filter** — Find jobs by company, role, or filter by status

### 🤖 AI-Powered Features
- **AI Extraction** — Paste a job description or URL, AI extracts all structured data
- **JobBot AI Coach** — Conversational AI assistant for interview prep, resume tips, salary negotiation
- **AI Job Analysis** — Get strategic insights about your overall job search
- **Per-Job AI Advice** — Personalized next steps based on application status
- **Smart Preview** — Review extracted data before saving

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
- **Web PWA** — Installable Progressive Web App, works in any browser
- **Android** — Native Flutter app
- **Chrome Extension** — Capture jobs directly from job listing pages
- **Responsive** — Works on mobile and desktop viewports

---

## 🏗 Tech Stack

| Layer | Technology | Hosted On |
|-------|-----------|-----------|
| **Frontend** | Flutter 3.32 (Dart) | Firebase Hosting |
| **Backend** | FastAPI (Python 3.14) | Render.com (Free) |
| **Database** | Firebase Firestore | Google Cloud |
| **Auth** | Firebase Authentication | Google Cloud |
| **AI** | Google Gemini 1.5 Flash (Free) | Google AI |
| **Scraping** | BeautifulSoup4 | Backend |
| **State Mgmt** | Provider | — |

---

## 📁 Project Structure

```
cross-platform-Job-Application-Tracker/
│
├── 📂 backend/                          # FastAPI Backend (Python)
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                      # App entry, CORS, router registration
│   │   ├── config.py                    # Environment config (Pydantic Settings)
│   │   ├── 📂 models/
│   │   │   ├── job.py                   # Job, AI Chat, AI Analyze Pydantic schemas
│   │   │   └── user.py                  # User signup/login schemas
│   │   ├── 📂 routers/
│   │   │   ├── auth.py                  # POST /auth/signup, /auth/login
│   │   │   ├── jobs.py                  # GET/POST/PUT/DELETE /jobs
│   │   │   ├── ai.py                    # POST /ai/extract, /ai/chat, /ai/analyze, /ai/advice
│   │   │   └── extension.py             # POST /extension/scrape, /check, /capture
│   │   ├── 📂 services/
│   │   │   ├── firebase_service.py      # Firebase Auth + Firestore operations
│   │   │   ├── ai_service.py            # Gemini AI: extract, chat, analyze, advice
│   │   │   └── scraper_service.py       # BeautifulSoup web scraping
│   │   └── 📂 middleware/
│   │       └── auth_middleware.py       # Firebase token verification middleware
│   ├── serviceAccountKey.json           # Firebase Admin credentials
│   ├── requirements.txt                 # Python dependencies
│   ├── Dockerfile                       # Docker config (for containerized deploy)
│   ├── .dockerignore
│   ├── .env                             # Local environment variables
│   └── .env.example                     # Environment variables template
│
├── 📂 frontend/                         # Flutter Web/Android App
│   ├── 📂 lib/
│   │   ├── main.dart                    # App entry, theme config, auth routing
│   │   ├── 📂 config/
│   │   │   └── api_config.dart          # Backend URL + endpoint constants
│   │   ├── 📂 models/
│   │   │   ├── job_model.dart           # JobModel, JobStatus, JobSource enums
│   │   │   └── user_model.dart          # UserModel for auth state
│   │   ├── 📂 services/
│   │   │   ├── auth_service.dart        # Login/signup API calls
│   │   │   ├── job_service.dart         # CRUD job API calls
│   │   │   └── ai_service.dart          # AI extract/chat/analyze/advice calls
│   │   ├── 📂 providers/
│   │   │   ├── auth_provider.dart       # Auth state + auto-login
│   │   │   └── job_provider.dart        # Jobs state, filters, analytics
│   │   ├── 📂 screens/
│   │   │   ├── login_screen.dart        # Email/password login (glassmorphism UI)
│   │   │   ├── signup_screen.dart       # Registration screen
│   │   │   ├── dashboard_screen.dart    # Analytics + job list + navigation
│   │   │   ├── add_job_screen.dart      # Manual job entry form
│   │   │   ├── job_detail_screen.dart   # Job details, status update, delete
│   │   │   ├── ai_extract_screen.dart   # AI extraction from text/URL
│   │   │   └── ai_chat_screen.dart      # 🆕 JobBot AI Job Coach chat interface
│   │   └── 📂 widgets/
│   │       ├── job_card.dart            # Job list card with status badge
│   │       ├── analytics_chart.dart     # Pie chart for status distribution
│   │       ├── search_filter_bar.dart   # Search + status/source filters
│   │       ├── status_badge.dart        # Color-coded status pill widget
│   │       └── ad_banner.dart           # Ad banner stub (web-safe)
│   ├── 📂 web/                          # PWA configuration
│   │   ├── index.html
│   │   ├── manifest.json                # PWA manifest (installable)
│   │   └── flutter_service_worker.js    # PWA service worker
│   ├── 📂 android/                      # Android native config
│   ├── pubspec.yaml                     # Flutter dependencies
│   └── analysis_options.yaml
│
├── 📂 chrome-extension/                 # Chrome Browser Extension
│   ├── manifest.json                    # Extension manifest (MV3)
│   ├── 📂 background/
│   │   └── service_worker.js            # Tab change listener, badge updates
│   ├── 📂 content/
│   │   └── content_script.js            # DOM extraction from job pages
│   ├── 📂 popup/
│   │   ├── popup.html                   # Extension popup UI
│   │   ├── popup.css                    # Popup styles
│   │   └── popup.js                     # Popup logic (AI scrape, capture)
│   ├── 📂 options/
│   │   ├── options.html                 # Settings page UI
│   │   └── options.js                   # Settings logic (API URL, logout)
│   └── 📂 icons/                        # Extension icons (16/48/128px)
│
├── render.yaml                          # Render.com deployment config
├── firebase.json                        # Firebase Hosting config
├── .firebaserc                          # Firebase project binding
├── .gitignore
└── README.md
```

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Health check |
| `POST` | `/api/auth/signup` | Register new user |
| `POST` | `/api/auth/login` | Login and get token |
| `GET` | `/api/jobs` | List all jobs (with filters) |
| `POST` | `/api/jobs/` | Create new job |
| `GET` | `/api/jobs/{id}` | Get job details |
| `PUT` | `/api/jobs/{id}` | Update job |
| `DELETE` | `/api/jobs/{id}` | Delete job |
| `POST` | `/api/ai/extract` | 🤖 AI job extraction from text/URL |
| `POST` | `/api/ai/chat` | 🤖 AI job coach conversation |
| `POST` | `/api/ai/analyze` | 🤖 AI analysis of all applications |
| `POST` | `/api/ai/advice` | 🤖 AI advice for specific job |
| `POST` | `/api/extension/scrape` | Chrome extension — scrape + extract |
| `POST` | `/api/extension/check` | Chrome extension — domain check |
| `POST` | `/api/extension/capture` | Chrome extension — save job |

All `/jobs`, `/ai`, and `/extension` endpoints require `Authorization: Bearer <token>` header.

---

## 🚀 Getting Started (Local Development)

### Prerequisites
- **Flutter** 3.x
- **Python** 3.11+
- **Firebase** project (already configured — credentials in repo)

### 1. Backend Setup

```bash
cd backend
python -m venv venv
venv\Scripts\activate      # Windows
pip install -r requirements.txt

# The .env file is already configured
uvicorn app.main:app --reload --port 8000
```

API available at `http://localhost:8000/docs`

### 2. Frontend Setup

```bash
cd frontend
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Or build for web
flutter build web --release
```

> Update `lib/config/api_config.dart` to use `http://localhost:8000/api` for local dev.

---

## ☁️ Cloud Deployment

### Backend — Render.com (Already Deployed)
- Connected to GitHub: `aswathraj01/cross-platform-Job-Application-Tracker`
- Root directory: `backend/`
- Auto-deploys on push to `main`
- Live at: `https://job-tracker-api-i9hd.onrender.com`

### Frontend — Firebase Hosting (Already Deployed)
```bash
flutter build web --release
firebase deploy --only hosting
```
- Live at: `https://job-application-tracker-9f4d8.web.app`

---

## 🎨 UI Screens

| Screen | Description |
|--------|-------------|
| **Login** | Email/password with dark glass design |
| **Signup** | Registration with password confirmation |
| **Dashboard** | Analytics cards, pie chart, job list, search & filter |
| **Add Job** | Full form with status dropdown, date picker, skills chips |
| **Job Details** | View details, update status, delete, open link |
| **AI Extract** | Paste text or URL, preview results, confirm status |
| **JobBot Chat** | 🆕 Conversational AI job coach with suggestions |

---

## 🤖 AI Features (Gemini 1.5 Flash — Free)

| Feature | Endpoint | Description |
|---------|----------|-------------|
| **Job Extraction** | `/api/ai/extract` | Extracts company, role, location, skills from job description |
| **AI Job Coach** | `/api/ai/chat` | Conversational chatbot for interview prep, resume, salary tips |
| **Application Analysis** | `/api/ai/analyze` | Insights on your overall job search strategy |
| **Job-Specific Advice** | `/api/ai/advice` | Personalized next steps for each application |

---

## 🔒 Security

- Firebase ID token verification on all protected endpoints
- Pydantic input validation on backend
- Form validation on frontend
- Jobs scoped per user (Firestore subcollections)
- Environment variables for all secrets
- `.gitignore` excludes `.env` and sensitive files

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) — Cross-platform UI toolkit
- [FastAPI](https://fastapi.tiangolo.com) — Modern Python web framework
- [Firebase](https://firebase.google.com) — Backend-as-a-Service
- [Google Gemini](https://ai.google.dev) — AI-powered extraction & coaching
- [Render.com](https://render.com) — Free cloud hosting for the backend
- [fl_chart](https://pub.dev/packages/fl_chart) — Beautiful charts for Flutter