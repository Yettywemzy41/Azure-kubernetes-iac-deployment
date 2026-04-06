terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.5"
    }
  }

  # --- REMOTE STATE CONFIGURATION ---
  backend "azurerm" {
    resource_group_name  = "state-rg"
    storage_account_name = "state7674" # Replace with your actual name
    container_name       = "state"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true                      # This is the production-secure way
  }
} # <--- This brace CLOSES the terraform settings block

# --- ACTIVE PROVIDER CONFIGURATIONS ---

provider "azurerm" {
  features {}
}

provider "azapi" {
  # No extra config needed here, it inherits from your Azure CLI login
}
