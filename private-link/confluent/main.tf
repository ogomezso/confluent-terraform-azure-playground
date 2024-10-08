resource "confluent_environment" "env" {
  display_name = var.cc_env_name
  stream_governance {
    package = "ADVANCED"
  }
}

resource "confluent_network" "private-link" {
  display_name     = var.cc_network_name
  cloud            = "AZURE"
  region           = var.region
  connection_types = ["PRIVATELINK"]
  environment {
    id = confluent_environment.env.id
  }
  dns_config {
    resolution = "PRIVATE"
  }
}

resource "confluent_private_link_access" "azure" {
  display_name = "Azure Private Link Access"
  azure {
    subscription = var.subscription_id
  }
  environment {
    id = confluent_environment.env.id
  }
  network {
    id = confluent_network.private-link.id
  }
}


resource "confluent_kafka_cluster" "kafka-cluster" {
  display_name = var.cc_kafka_cluster_name
  availability = var.cc_availability
  cloud        = confluent_network.private-link.cloud
  region       = confluent_network.private-link.region
  dedicated {
    cku = var.cc_cku
  }
  environment {
    id = confluent_environment.env.id
  }
  network {
    id = confluent_network.private-link.id
  }
}

resource "confluent_service_account" "admin-sa" {
  display_name = "${confluent_kafka_cluster.kafka-cluster.display_name}-sa-admin"
  description  = "Service account to manage 'inventory' Kafka cluster"
}

resource "confluent_role_binding" "admin-sa-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.admin-sa.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.kafka-cluster.rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "${confluent_kafka_cluster.kafka-cluster.display_name}-kafka-admin-api-key"
  description  = "Kafka Admin API Key that is owned by ${confluent_service_account.admin-sa.display_name} service account"

  # Set optional `disable_wait_for_ready` attribute (defaults to `false`) to `true` if the machine where Terraform is not run within a private network
  disable_wait_for_ready = true

  owner {
    id          = confluent_service_account.admin-sa.id
    api_version = confluent_service_account.admin-sa.api_version
    kind        = confluent_service_account.admin-sa.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.kafka-cluster.id
    api_version = confluent_kafka_cluster.kafka-cluster.api_version
    kind        = confluent_kafka_cluster.kafka-cluster.kind

    environment {
      id = confluent_environment.env.id
    }
  }

  depends_on = [
    confluent_role_binding.admin-sa-kafka-cluster-admin,
    confluent_private_link_access.azure
  ]
}

provider "azurerm" {
  features {}
}

locals {
  dns_domain = confluent_network.private-link.dns_domain
  network_id = split(".", local.dns_domain)[0]
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  for_each = var.subnet_name_by_zone

  name                 = each.value
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "hz" {
  resource_group_name = data.azurerm_resource_group.rg.name

  name = local.dns_domain
}

resource "azurerm_private_endpoint" "endpoint" {
  for_each = var.subnet_name_by_zone

  name                = "confluent-${local.network_id}-${each.key}"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.rg.name

  subnet_id = data.azurerm_subnet.subnet[each.key].id

  private_service_connection {
    name                              = "confluent-${local.network_id}-${each.key}"
    is_manual_connection              = true
    private_connection_resource_alias = lookup(confluent_network.private-link.azure[0].private_link_service_aliases, each.key, "\n\nerror: ${each.key} subnet is missing from CCN's Private Link service aliases")
    request_message                   = "PL"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "hz" {
  name                  = data.azurerm_virtual_network.vnet.name
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.hz.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_a_record" "rr" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.hz.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 60
  records = [
    for _, ep in azurerm_private_endpoint.endpoint : ep.private_service_connection[0].private_ip_address
  ]
}

resource "azurerm_private_dns_a_record" "zonal" {
  for_each = var.subnet_name_by_zone

  name                = "*.az${each.key}"
  zone_name           = azurerm_private_dns_zone.hz.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 60
  records = [
    azurerm_private_endpoint.endpoint[each.key].private_service_connection[0].private_ip_address,
  ]
}
