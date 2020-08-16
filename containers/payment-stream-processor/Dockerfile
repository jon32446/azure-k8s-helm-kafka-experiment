FROM python:3-slim

# Install our Python requirements
COPY requirements.txt /app/
RUN ["pip", "install", "--no-cache", "-r", "/app/requirements.txt", "-t", "/app"]

COPY payment-stream-processor.py /app/

WORKDIR /app

# Change to a non-privileged user
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --no-create-home \
    --uid "16132" \
    "appuser"

USER appuser

# Run the app
CMD ["python", \
    "payment-stream-processor.py"]
