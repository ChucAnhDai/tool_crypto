# Base image: python:3.12-slim
FROM python:3.12-slim

# WORKDIR: /app
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# COPY requirements.txt first (layer cache optimization)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# COPY all source files
COPY . .

# Expose API port
EXPOSE 8000

# --reload enables hot reload in dev
# CMD to start FastAPI with uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
