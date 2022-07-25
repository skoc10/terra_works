# Cluster Identity
output "cluster_client_id" {
  value = azuread_service_principal.cluster_sp.application_id
}

output "cluster_sp_secret" {
  sensitive = true
  value     = azuread_service_principal_password.cluster_sp_password.value
}

