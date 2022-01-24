# Backend using Azure blob storage

## Using Azure CLI

<https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage>

```
RESOURCE_GROUP_NAME=tstate
STORAGE_ACCOUNT_NAME=tstate$RANDOM
CONTAINER_NAME=tstate
```

## Create resource group

```
az group create --name $RESOURCE_GROUP_NAME --location <eastus>
```

## Create storage account

```
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
```

## Get storage account key

```
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
```

## Create blob container

```
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
```

## Create a key vault

<https://docs.microsoft.com/en-us/azure/key-vault/secrets/quick-create-cli>

```
az keyvault create --name "<avdkeyvaultdemo>" --resource-group $RESOURCE_GROUP_NAME --location "<East US>"
```

## Add storage account access key to key vault

```
az keyvault secret set --vault-name "<avdkeyvaultdemo>" --name terraform-backend-key --value "<W.........................................>"
```
