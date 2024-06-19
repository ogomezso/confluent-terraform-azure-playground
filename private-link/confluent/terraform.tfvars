# The name of the Azure Resource Group that the virtual network belongs to
# You can find the name of your Azure Resource Group in the [Azure Portal on the Overview tab of your Azure Virtual Network](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Network%2FvirtualNetworks).
resource_group = "ogomezso-se"

# The name of your VNet that you want to connect to Confluent Cloud Cluster
# You can find the name of your Azure VNet in the [Azure Portal on the Overview tab of your Azure Virtual Network](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Network%2FvirtualNetworks).
vnet_name = "ogomezso-vnet"

# The region of your Azure VNet
region = "westeurope"

# A map of Zone to Subnet Name
# On Azure, zones are Confluent-chosen names (for example, `1`, `2`, `3`) since Azure does not have universal zone identifiers.
subnet_name_by_zone = {
  "inditex_pl_1" = "default",
  "inditex_pl_2" = "default",
  "inditex_pl_3" = "default",
}

cc_env_name = "ogomez_inditex_mqtt"

cc_sr_package = "ADVANCED"

cc_network_name = "ogomez_inditex_mqtt_nwk"

cc_kafka_cluster_name = "ogomez_inditex_mqtt"

cc_cku = 2

cc_availability = "SINGLE_ZONE"

