# ---------- builder ----------
FROM python:3.11-slim AS builder
ENV PIP_NO_CACHE_DIR=1
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install -r requirements.txt \
 && find /opt/venv -type d -name "__pycache__" -prune -exec rm -rf {} + \
 && find /opt/venv -type d \( -name tests -o -name test \) -prune -exec rm -rf {} + \
 && rm -rf /opt/venv/lib/python3.11/site-packages/pip* \
           /opt/venv/lib/python3.11/site-packages/setuptools*

# ---------- runtime ----------
FROM gcr.io/distroless/python3-debian12:nonroot
WORKDIR /app
COPY --from=builder /opt/venv/lib/python3.11/site-packages /app/site-packages
COPY app.py .
ENV PYTHONPATH=/app/site-packages PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
ENTRYPOINT ["python3", "-m", "gunicorn", "-b", "0.0.0.0:8000", "app:app"]
