#============================================================================
# Create a Kubernetes NGINX Ingress controller
#============================================================================

# Create a namespace for the ingress controller
kubectl create namespace ingress

# Add the stable repo to helm
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Use helm to install the NGINX Ingress controller
helm install nginx-ingress stable/nginx-ingress \
    --namespace ingress \
    --set controller.replicaCount=1

# Check the progress (optional)
kubectl get service nginx-ingress-controller --namespace ingress -w

# Create the ingress resource in kubernetes
kubectl apply -f ppap-ingress.yaml
