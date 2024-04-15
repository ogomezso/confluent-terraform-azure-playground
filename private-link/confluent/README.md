<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.7.0 |
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | >=1.68.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 2.55.0 |
| <a name="provider_confluent"></a> [confluent](#provider\_confluent) | 1.68.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_a_record.rr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_a_record.zonal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.hz](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.hz](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [confluent_api_key.app-manager-kafka-api-key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_environment.env](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/environment) | resource |
| [confluent_kafka_cluster.kafka-cluster](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_cluster) | resource |
| [confluent_network.private-link](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/network) | resource |
| [confluent_private_link_access.azure](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/private_link_access) | resource |
| [confluent_role_binding.admin-sa-kafka-cluster-admin](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_schema_registry_cluster.schema_registry](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/schema_registry_cluster) | resource |
| [confluent_service_account.admin-sa](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cc_availability"></a> [cc\_availability](#input\_cc\_availability) | Confluent Cloud Kafka Cluster display name | `string` | n/a | yes |
| <a name="input_cc_cku"></a> [cc\_cku](#input\_cc\_cku) | Confluent Cloud Kafka Cluster number of CKUs | `number` | n/a | yes |
| <a name="input_cc_kafka_cluster_name"></a> [cc\_kafka\_cluster\_name](#input\_cc\_kafka\_cluster\_name) | Confluent Cloud Kafka Cluster display name | `string` | n/a | yes |
| <a name="input_cc_network_name"></a> [cc\_network\_name](#input\_cc\_network\_name) | Confluent Cloud Network display name | `string` | n/a | yes |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Confluent Cloud Environment display name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region of your Azure VNet | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the Azure Resource Group that the virtual network belongs to | `string` | n/a | yes |
| <a name="input_subnet_name_by_zone"></a> [subnet\_name\_by\_zone](#input\_subnet\_name\_by\_zone) | A map of Zone to Subnet Name | `map(string)` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Azure subscription ID to enable for the Private Link Access where your VNet exists | `string` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of your Azure VNet that you want to connect to Confluent Cloud Cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource-ids"></a> [resource-ids](#output\_resource-ids) | n/a |

<!-- END_TF_DOCS -->