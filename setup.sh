#!/bin/bash

# Variables
RESOURCE_GROUP_NAME="state-rg"
STORAGE_ACCOUNT_NAME="state$RANDOM" # Random name for uniqueness
CONTAINER_NAME="state"
LOCATION="eastus"

echo "1. Creating Resource Group..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

echo "2. Creating Storage Account (Management)..."
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --allow-blob-public-access false

echo "3. Creating Container (Data - Using Login Auth)..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --auth-mode login
