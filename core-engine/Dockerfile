# Base image: python:3.12-slim
FROM python:3.12-slim

# WORKDIR: /app
WORKDIR /app

# Install system dependencies
# ta-lib requires build-essential
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# COPY requirements.txt first (layer cache optimization)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# COPY all source files
COPY . .

# CMD to start the core engine orchestrator
CMD ["python", "main.py"]
