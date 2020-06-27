#============================================================================
# Create the Azure container registry
#============================================================================

#----------------------------------------------------------------------------
# Config
#----------------------------------------------------------------------------
REGION_NAME=westeurope
RESOURCE_GROUP=ppap-rg
ACR_NAME=ppapcr
SERVICE_PRINCIPAL_NAME=acr-service-principal

#----------------------------------------------------------------------------
# Container registry
#----------------------------------------------------------------------------
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic

#----------------------------------------------------------------------------
# Create service principal for the GitHub action to push an image to ACR
#----------------------------------------------------------------------------

ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)
SP_PASSWD=$(az ad sp create-for-rbac --name http://$SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role AcrPush --role AcrDelete --query password --output tsv)
SP_APP_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL_NAME --query appId --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $SP_APP_ID"
echo "Service principal password: $SP_PASSWD"
