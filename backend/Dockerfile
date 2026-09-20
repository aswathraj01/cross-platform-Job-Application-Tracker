FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

# Firebase credentials are injected at runtime via the FIREBASE_CREDENTIALS_BASE64
# environment variable — no file copy needed. See firebase_service.py for details.

# Expose port
EXPOSE 10000

# Run the application
# Render.com sets PORT env var; default to 10000 (Render's default for web services)
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-10000}"]
