#============================================================================
# Create the Azure container registry
#============================================================================

#----------------------------------------------------------------------------
# Config
#----------------------------------------------------------------------------
REGION_NAME=westeurope
RESOURCE_GROUP=ppap-rg
ACR_NAME=ppapcr
AKS_CLUSTER_NAME=ppap-kube
SERVICE_PRINCIPAL_NAME=acr-service-principal

#----------------------------------------------------------------------------
# Container registry
#----------------------------------------------------------------------------
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic

#----------------------------------------------------------------------------
# Attach container registry to Kubernetes cluster
#----------------------------------------------------------------------------

az aks update \
    --name $AKS_CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --attach-acr $ACR_NAME

#----------------------------------------------------------------------------
# Create service principal for the GitHub action to push an image to ACR
#----------------------------------------------------------------------------

ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)
SP_PASSWD=$(az ad sp create-for-rbac --name http://$SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --query password --output tsv)
SP_APP_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL_NAME --query appId --output tsv)

az role assignment create --role AcrPush   --assignee $SP_APP_ID --scope $ACR_REGISTRY_ID
az role assignment create --role AcrDelete --assignee $SP_APP_ID --scope $ACR_REGISTRY_ID

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $SP_APP_ID"
echo "Service principal password: $SP_PASSWD"
