# Configure the Confluent Cloud Provider
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">=1.68.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.55.0"
    }
  } 
}
