# Job Tracker Chrome Extension

A professional Manifest V3 Chrome extension that lets you capture job applications from any job portal with one click.

## Features

- 🧩 **One-click capture** — Click the extension icon on any job page to auto-extract job details via AI
- 🤖 **AI-powered extraction** — Sends the page content to your backend Gemini AI to extract Company, Role, Location, Skills
- ✅ **Already Applied badge** — Shows a green ✓ badge on sites where you've previously tracked a job
- 🔐 **Secure auth** — Uses your Job Tracker account credentials
- ⚙️ **Configurable** — Point it at any backend URL via the options page

## Setup

### 1. Load in Chrome (Developer Mode)

1. Open Chrome and go to `chrome://extensions`
2. Enable **Developer Mode** (toggle top-right)
3. Click **Load Unpacked**
4. Select the `chrome-extension/` folder

### 2. Configure Backend URL

The extension needs to reach your backend. Options:

**Option A — Local Development (with ngrok):**
```bash
# Install ngrok: https://ngrok.com/download
ngrok http 8000
# Copy the https://xxxx.ngrok.io URL
```
Then open the extension's **Settings** (gear icon) and set the API URL to:
```
https://xxxx.ngrok.io/api
```

**Option B — Deployed Backend:**
Set the API URL in settings to your production URL, e.g.:
```
https://your-app.railway.app/api
```

### 3. Sign In

Click the extension icon → enter your Job Tracker email and password.

## How It Works

1. Navigate to any job posting page (LinkedIn, Indeed, Naukri, Glassdoor, company career pages, etc.)
2. Click the **Job Tracker** extension icon in your Chrome toolbar
3. The extension:
   - Checks if you've already applied to jobs from this domain
   - Sends the page HTML to your backend for AI extraction
   - Shows extracted Company, Role, Location, and Skills
4. Review the details, set your status (Applied/Not Applied), and click **Save to Tracker**
5. The job appears instantly in your dashboard with the 🧩 Extension badge

## Files

```
chrome-extension/
├── manifest.json          # Extension manifest (V3)
├── popup/
│   ├── popup.html         # Popup UI (5 states)
│   ├── popup.css          # Dark theme styles
│   └── popup.js           # All popup logic
├── content/
│   └── content.js         # Content script (page scraping)
├── background/
│   └── service_worker.js  # Badge updates
├── options/
│   ├── options.html       # Settings page
│   └── options.js         # Settings logic
└── icons/
    ├── icon16.png
    ├── icon48.png
    └── icon128.png
```
