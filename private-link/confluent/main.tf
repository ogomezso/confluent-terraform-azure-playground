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
  features {
  }
}

locals {
  hosted_zone = length(regexall(".glb", confluent_kafka_cluster.kafka-cluster.bootstrap_endpoint)) > 0 ? replace(regex("^[^.]+-([0-9a-zA-Z]+[.].*):[0-9]+$", confluent_kafka_cluster.kafka-cluster.rest_endpoint)[0], "glb.", "") : regex("[.]([0-9a-zA-Z]+[.].*):[0-9]+$", confluent_kafka_cluster.kafka-cluster.bootstrap_endpoint)[0]
  network_id  = regex("^([^.]+)[.].*", local.hosted_zone)[0]
}
