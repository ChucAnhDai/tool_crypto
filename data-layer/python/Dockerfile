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

# Dev: volume mount overrides /app for hot reload
# CMD to run the data collection entrypoint
CMD ["python", "main.py"]
