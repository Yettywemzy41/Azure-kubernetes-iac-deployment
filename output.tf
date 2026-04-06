# 1. Essential for identifying where the resources live
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

# 2. Useful for scripts or automation
output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

# 3. The "Production Way" to get access
# Instead of certificates, we output the exact command to log in
output "configure_kubectl" {
  description = "Run this command to configure your local kubectl to connect to the cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.k8s.name}"
}

# 4. The API server address (Useful for CI/CD pipelines)
output "host" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  sensitive = true
}
