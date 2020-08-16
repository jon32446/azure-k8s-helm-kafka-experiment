#============================================================================
# Create a Storage Account to use Azure Table Storage
#============================================================================

#----------------------------------------------------------------------------
# Config
#----------------------------------------------------------------------------
REGION_NAME=westeurope
RESOURCE_GROUP=ppap-rg
STORAGE_ACCOUNT_NAME=ppaptablestorage

#----------------------------------------------------------------------------
# Storage account
#----------------------------------------------------------------------------

# Create the account
az storage account create \
    --resource-group $RESOURCE_GROUP \
    --location $REGION_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS \
    --kind StorageV2 \
    --https-only true \
    --min-tls-version TLS1_2

# Get an access key
STORAGE_ACCOUNT_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query "[?keyName=='key1'].value" -o tsv)

# Create the account table
az storage table create \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_ACCOUNT_KEY \
    --name "account"

#----------------------------------------------------------------------------
# Kubernetes secret config
#----------------------------------------------------------------------------

# Create a Kubernetes secret with the connection string
kubectl create secret generic ppaptablestorage-connection-string \
    --from-literal=connection_string="DefaultEndpointsProtocol=https;AccountName=$STORAGE_ACCOUNT_NAME;AccountKey=$STORAGE_ACCOUNT_KEY;EndpointSuffix=core.windows.net"
