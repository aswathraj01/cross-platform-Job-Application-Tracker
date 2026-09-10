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

# Copy Firebase service account key (injected via Cloud Run secret or build)
# NOTE: In production, this is mounted via Secret Manager — see README
COPY serviceAccountKey.json ./serviceAccountKey.json

# Expose port
EXPOSE 8080

# Run the application
# Cloud Run uses PORT env var, default to 8080
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
