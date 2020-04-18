FROM python:3-alpine

# Install uWSGI with Python extension
RUN apk add --no-cache uwsgi-python3

# For debug purposes, add a bash shell
RUN apk add --no-cache bash

# Install our Python requirements
COPY requirements.txt /app/
RUN ["pip", "install", "--no-cache", "-r", "/app/requirements.txt", "-t", "/app"]

COPY server.py /app/

WORKDIR /app

# Expose application server
EXPOSE 3031

CMD ["uwsgi", \
    "--plugins", "python3", \
    "--socket", "0.0.0.0:3031", \
    "--wsgi-file", "/app/server.py", \
    "--callable", "app", \
    "--processes", "4", \
    "--threads", "2", \
    "--stats", "127.0.0.1:9191"]
