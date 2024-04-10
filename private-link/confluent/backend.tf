terraform {
  backend "azurerm" {
    resource_group_name  = "ogomezso"
    storage_account_name = "ogomezsostorage"
    container_name       = "pltfstate"
    key                  = "terraform.tfstate"
    use_oidc              = true
  }
}