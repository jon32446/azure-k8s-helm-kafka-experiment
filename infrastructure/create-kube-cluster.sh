#============================================================================
# Create the Azure Kubernetes cluster
#============================================================================

#----------------------------------------------------------------------------
# Config
#----------------------------------------------------------------------------
REGION_NAME=westeurope
RESOURCE_GROUP=ppap-rg
SUBNET_NAME=ppap-kube-subnet
VNET_NAME=ppap-kube-vnet
AKS_CLUSTER_NAME=ppap-kube

#----------------------------------------------------------------------------
# Resource group
#----------------------------------------------------------------------------
az group create \
    --name $RESOURCE_GROUP \
    --location $REGION_NAME

#----------------------------------------------------------------------------
# Virtual network
#----------------------------------------------------------------------------
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --location $REGION_NAME \
    --name $VNET_NAME \
    --address-prefixes 10.0.0.0/8 \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix 10.240.0.0/16

SUBNET_ID=$(az network vnet subnet show \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET_NAME \
    --query id -o tsv)

#----------------------------------------------------------------------------
# Kubernetes cluster
#----------------------------------------------------------------------------
# Get latest, non-preview version of Kube
VERSION=$(az aks get-versions \
    --location $REGION_NAME \
    --query 'orchestrators[?!isPreview] | [-1].orchestratorVersion' \
    --output tsv)

# --network-plugin azure means the cluster will use Azure Container Networking Interface (CNI), the
# AKS cluster is connected to existing virtual network resources and configurations. In this
# networking model, every pod gets an IP address from the subnet and can be accessed directly.
# --node-vm-size B-series burstable VMs are ideal for workloads that do not need the full 
# performance of the CPU continuously, like web servers, small databases and development and test 
# environments. These workloads typically have burstable performance requirements. The B-Series 
# provides these customers the ability to purchase a VM size with a price conscious baseline 
# performance that allows the VM instance to build up credits when the VM is utilizing less than its
# base performance. When the VM has accumulated credit, the VM can burst above the VM’s baseline 
# using up to 100% of the CPU when your application requires the higher CPU performance.
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --vm-set-type VirtualMachineScaleSets \
    --load-balancer-sku basic \
    --location $REGION_NAME \
    --kubernetes-version $VERSION \
    --network-plugin azure \
    --vnet-subnet-id $SUBNET_ID \
    --service-cidr 10.2.0.0/24 \
    --dns-service-ip 10.2.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --generate-ssh-keys \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3 \
    --node-count 1 \
    --node-vm-size Standard_B2s

# Retrieve cluster credentials into kubectl context
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME

# Confirm node is available
kubectl get nodes

#----------------------------------------------------------------------------
# Grant the Kube cluster access to the Azure VNet
#----------------------------------------------------------------------------
AKS_SERVICE_PRINCIPAL_ID=$(az aks list --query "[?name=='ppap-kube'].servicePrincipalProfile.clientId" -o tsv)

az role assignment create --role "Network Contributor" --assignee $AKS_SERVICE_PRINCIPAL_ID --scope $SUBNET_ID
