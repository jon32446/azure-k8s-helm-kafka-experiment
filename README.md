# paypineapple-applepay
Learning project for Azure Kubernetes Service, Helm, Kafka and Azure Table Storage. Load testing with Locust. 

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

Open a command prompt with the virtual environment activated. Shortcut to do this is to just
double-click "!_SHELL.cmd".

Run flask locally

    cd containers\uwsgi-server
    python server.py

Or run the app using Kubernetes, with uWSGI as the app server and NGINX as the reverse proxy.

    kubectl apply -f kubernetes.yaml

# Smoke Testing

Run one of the following curl commands (Kubernetes):

    curl localhost:30001
    curl localhost:30001/time

Run one of the following curl commands (Flask dev):

    curl localhost:5000
    curl localhost:5000/time

# Load Testing

Create another virtual environment for the locust test and install requirements. Then run:

    cd load-test
    python -m locust

The web interface will spin up and is locally accessible at http://localhost:8089

Monitor the horizontal pod autoscaler and the nodes with the following:

    kubectl get hpa -w
    kubectl get nodes -w
