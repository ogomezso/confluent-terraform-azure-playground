terraform {
  backend "azurerm" {
    resource_group_name  = "ogomezso-se"
    storage_account_name = "ogomezsotfstorage"
    container_name       = "pltfstate"
    key                  = "terraform.tfstate"
  }
}
