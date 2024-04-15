variable "resource_group" {
  description = "The name of the Azure Resource Group that the virtual network belongs to"
  type        = string
}

variable "region" {
  description = "The region of your Azure VNet"
  type        = string
}

variable "vnet_name" {
  description = "The name of your Azure VNet that you want to connect to Confluent Cloud Cluster"
  type        = string
}

variable "subnet_name_by_zone" {
  description = "A map of Zone to Subnet Name"
  type        = map(string)
}

variable "subscription_id" {
  description = "The Azure subscription ID to enable for the Private Link Access where your VNet exists"
  type        = string
}

variable "cc_env_name" {
  description = "Confluent Cloud Environment display name"
  type        = string
}

variable "cc_sr_package" {
  type    = string
  default = "ESSENTIALS"
  validation {
    condition = (
    contains(["ESSENTIALS", "ADVANCED"], var.cc_sr_package)
    )
    error_message = <<EOT
sr_package => ESSENTIALS, ADVANCED
    EOT
  }
}

variable "cc_network_name" {
  description = "Confluent Cloud Network display name"
  type        = string
}

variable "cc_kafka_cluster_name" {
  description = "Confluent Cloud Kafka Cluster display name"
  type        = string
}

variable "cc_cku" {
  description = "Confluent Cloud Kafka Cluster number of CKUs"
  type        = number
}

variable "cc_availability" {
  description = "Confluent Cloud Kafka Cluster display name"
  type        = string
  validation {
    condition = (contains(["SINGLE_ZONE", "MULTI_ZONE"], var.cc_availability))
    error_message = "Not valid value, only SINGLE_ZONE or MULTI_ZONE are valid ones"
  }
}
