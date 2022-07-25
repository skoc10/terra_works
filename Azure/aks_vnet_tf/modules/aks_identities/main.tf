# Cluster Identity

resource "azuread_application" "cluster_aks" {
  display_name = var.cluster_name
}

resource "azuread_service_principal" "cluster_sp" {
  application_id = azuread_application.cluster_aks.application_id
}

# resource "random_string" "cluster_sp_password" {
#   length  = 32
#   special = true
#   keepers = {
#     service_principal = azuread_service_principal.cluster_sp.id
#   }
# }

# resource "azuread_service_principal_password" "cluster_sp_password" {
#   service_principal_id = azuread_service_principal.cluster_sp.id
#   value                = random_string.cluster_sp_password.result

#   # 1 year since creation
#   # https://www.terraform.io/docs/configuration/functions/timeadd.html
#   end_date = timeadd(timestamp(), "8760h")

#   lifecycle {
#     ignore_changes = [end_date]
#   }
# }

resource "time_rotating" "example" {
  rotation_days = 7
}

resource "azuread_service_principal_password" "cluster_sp_password" {
  service_principal_id = azuread_service_principal.cluster_sp.object_id
  rotate_when_changed = {
    rotation = time_rotating.example.id
  }
}
