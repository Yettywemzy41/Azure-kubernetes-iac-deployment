# 1. The Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name_prefix}-rg"
}

# 2. The AKS Cluster (The System Pool is inside here)
resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = "${var.resource_group_name_prefix}-cluster"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.resource_group_name_prefix}-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "systempool"
    vm_size    = "Standard_D2s_v3"
    node_count = var.node_count
  }

  linux_profile {
    admin_username = var.username

    ssh_key {
      # Pulls the key from your ssh.tf file
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

# 3. The Secondary Node Pool (Your Affinity Pool)
resource "azurerm_kubernetes_cluster_node_pool" "internal" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_D2s_v3"
  node_count            = 1

  node_labels = {
    "color" = "blue"
  }
}
