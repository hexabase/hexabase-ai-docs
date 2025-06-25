# Multi-stage build for Hexabase.AI Documentation
FROM python:3.12-slim as builder

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Build documentation for both languages
RUN mkdocs build --clean
RUN mkdocs build --config-file mkdocs.ja.yml --site-dir site/ja

# Production stage
FROM nginx:alpine

# Copy built documentation
COPY --from=builder /app/site /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Expose port
EXPOSE 80

# Labels
LABEL org.opencontainers.image.title="Hexabase.AI Documentation"
LABEL org.opencontainers.image.description="Multi-language documentation for Hexabase.AI"
LABEL org.opencontainers.image.source="https://github.com/KoribanDev/hexabase-ai-docs"
LABEL org.opencontainers.image.licenses="MIT"