output "resource-ids" {
  value = <<-EOT
  Environment ID:   ${confluent_environment.env.id}
  Kafka Cluster ID: ${confluent_kafka_cluster.kafka-cluster.id}

  Service Accounts and their Kafka API Keys (API Keys inherit the permissions granted to the owner):
  ${confluent_service_account.admin-sa.display_name}:                     ${confluent_service_account.admin-sa.id}
  ${confluent_service_account.admin-sa.display_name}'s Kafka API Key:     "${confluent_api_key.app-manager-kafka-api-key.id}"
  ${confluent_service_account.admin-sa.display_name}'s Kafka API Secret:  "${confluent_api_key.app-manager-kafka-api-key.secret}"

EOT
  sensitive = true
}
