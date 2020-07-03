#============================================================================
# Destroy all Azure resources associated with this project
#============================================================================

#----------------------------------------------------------------------------
# Config
#----------------------------------------------------------------------------
RESOURCE_GROUP=ppap-rg
AKS_CLUSTER_NAME=ppap-kube
ACR_SERVICE_PRINCIPAL_NAME=acr-service-principal

#----------------------------------------------------------------------------
# Remove the resource group and everything in it
#----------------------------------------------------------------------------
az group delete --name $RESOURCE_GROUP --yes

#----------------------------------------------------------------------------
# Clean up the service principals associated with AKS and ACR
#----------------------------------------------------------------------------
az ad sp delete --id $(az ad sp show --id http://$AKS_CLUSTER_NAME --query appId --output tsv)

az ad sp delete --id $(az ad sp show --id http://$ACR_SERVICE_PRINCIPAL_NAME --query appId --output tsv)
