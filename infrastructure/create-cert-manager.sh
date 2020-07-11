#============================================================================
# Create a Certificate Manager to enable TLS using Let's Encrypt
#============================================================================

#----------------------------------------------------------------------------
# Install jetstack/cert-manager from Helm chart
#----------------------------------------------------------------------------

# First create the Kubernetes custom resource definition used by cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager.crds.yaml

# Create a namespace for the cert-manager
kubectl create namespace cert-manager

# Add the jetstack repo to helm
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager \
    --namespace cert-manager \
    --version v0.15.2 \
    jetstack/cert-manager

# Confirm the chart is installed
kubectl get all --namespace cert-manager

#----------------------------------------------------------------------------
# Create the ClusterIssuer and update the Ingress
#----------------------------------------------------------------------------

kubectl apply -f ppap-cluster-issuer.yaml

kubectl apply -f ppap-ingress-tls.yaml

# Verify that it worked
kubectl describe cert ppap-web-cert
