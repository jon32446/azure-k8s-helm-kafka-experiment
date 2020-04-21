# paypineapple-applepay
Paypineapple-applepay is the future of payments

# Setup

Install Python3 using chocolatey (as administrator)

    choco install python3

Create a virtual environment called venv

    python -m venv venv

Activate the virtual environment

    venv\Scripts\activate.bat

Install the requirements in requirements.txt

    pip install -r requirements.txt

# Running

Open a command prompt with the virtual environment activated. Shortcut to do this is just
double-click "!_SHELL.cmd".

Run flask locally

    cd containers\uwsgi-server
    python server.py

Or run the app through uWSGI, with NGINX as the reverse proxy.

1. Start containers\nginx-alpine\run.cmd
2. Start containers\uwsgi-server\run.cmd
