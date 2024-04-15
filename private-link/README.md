# Dedicated cluster on Azure Private Link 
 
[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/ogomezso/confluent-terraform-azure-playground/blob/main/private-link/README.md)
[![es](https://img.shields.io/badge/lang-es-yellow.svg)](https://github.com/ogomezso/confluent-terraform-azure-playground/blob/main/private-link/README.es.md)


This example will use [Confluent's](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs) and [Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) terraform providers, to create:

- Confluent Cloud Environment
- Confluent Cloud Schema Registry
- Confluent Cloud Azure Private Network secured with Private Link
- Confluent Cloud Private Link Access
- Confluent Cloud Kafka Cluster
- Confluent Cloud Service Account (Cluster Admin)
- Azure Private DNS Hosted Zone
- Azure Private Endpoints
- Azure Virtual Network Links for Hosted Zone
- Azure DNS Records for both HZ and Zonal

> This is our recommended minimal set of resources to be managed by terraform state but keep in mind that any of this resources can be pre-created and substituted by data resources or created a posteriori dependending on the case.

## Prerequisites

As general requisite for some of the actions that the terraform script perform we will need access to Confluent Cloud Data plane (set up service accounts, role bindings,...) so since we are going to set up our cluster on a private link secured network we need to run it from a machine located on the private linked VNET.

On this example

### Azure

This example will create some resources over a **existing Azure resource group and VNET** so you need to have one of them already created and pass on a terraform variable file like this:

```terraform
resource_group = "ogomezso"

# The name of your VNet that you want to connect to Confluent Cloud Cluster
# You can find the name of your Azure VNet in the [Azure Portal on the Overview tab of your Azure Virtual Network](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Network%2FvirtualNetworks).
vnet_name = "ogomez-vnet"

# The region of your Azure VNet
region = "westeurope"

# A map of Zone to Subnet Name
# On Azure, zones are Confluent-chosen names (for example, `1`, `2`, `3`) since Azure does not have universal zone identifiers.
subnet_name_by_zone = {
  "1" = "default",
  "2" = "default",
  "3" = "default",
}
```

### Confluent Cloud

For running terraform script you will need to create a global [Confluent Cloud API Key](https://docs.confluent.io/cloud/current/access-management/authenticate/api-keys/api-keys.html?_ga=2.231529055.1958880784.1713172368-1450644743.1702551086&_gac=1.81281381.1711472085.CjwKCAjw5ImwBhBtEiwAFHDZx9ECrTVq-WTKbclHtPX2nUzZ6700UVxHeaOnCV7XOxDXs2ZrM7Mi7hoCe8YQAvD_BwE&_gl=1*mizv6d*_ga*MTQ1MDY0NDc0My4xNzAyNTUxMDg2*_ga_D2D3EGKSGD*MTcxMzE3MjM2OC42NDIuMC4xNzEzMTcyMzY4LjYwLjAuMA..#cloud-cloud-api-keys).

The best way to pass it to the terraform script is from a pair of environment variables: 

```text
CONFLUENT_CLOUD_API_KEY=<your_api_key>
CONFLUENT_CLOUD_API_SECRET=<your_api_secret>
```
In case your will run it through the `github action` you will need to create the proper github env secret, on the workflow example and to distinct to env variable itself that secrets must be named as:

```text
CCLOUD_API_KEY=<your_api_key>
CCLOUD_API_SECRET=<your_api_secret> 
```

### GitHub Action

Under the `.github/workflows` folder you can find a GH Action that allow you to spin up and destroy a cluster by running it manually.

There are some points to consider:

#### Action Runner

For putting to work the GitHub action the first thing we need to do is to set up a `self-host action runner` on the VNET linked to the Confluent Cloud Network. You can follow this [guide](https://www.cloudwithchris.com/blog/github-selfhosted-runner-on-azure/) to do so.

#### Terraform Backend

Another point is the your will need to store the `terraform state` on somewhere that can be accesible for the next workflow runs, our suggestion for this scenario is to set up it on a `azure blob storage container`.

To create a Azure blob storage container for Terraform State storage you can follow this [guide](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli).

We can set up this by setting the terraform backend to use such a tool:

````terraform
terraform {
  backend "azurerm" {
    resource_group_name  = "ogomezso"
    storage_account_name = "ogomezsostorage"
    container_name       = "pltfstate"
    key                  = "terraform.tfstate"
  }
}
````

On this example we are setting the authentication method to azure on basic client secret type by setting the required data as environment variables as [Github Actions Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) and referencing it on the action workflow:

````yaml
ARM_CLIENT_ID: ${{ secrets.AZ_CLIENT_ID }}
ARM_CLIENT_SECRET: ${{ secrets.AZ_CLIENT_SECRET }}
ARM_SUBSCRIPTION_ID: ${{ secrets.AZ_SUBSCRIPTION_ID }}
ARM_TENANT_ID: ${{ secrets.AZ_TENANT_ID }}
````

## Running

Once you set up your environment and all pre-requisites are fulfilled you just need to fill the `terraform.tfvars` with the proper values. This repository already contains an example on how to do:

```terraform
resource_group = "ogomezso"

vnet_name = "ogomez-vnet"

region = "westeurope"

subnet_name_by_zone = {
  "1" = "default",
  "2" = "default",
  "3" = "default",
}

env_name = "ogomez_azure_pl"

cc_network_name = "ogomez_azure_pl_nwk"

cc_kafka_cluster_name = "azure_dedicated_pl"

cc_cku = 2

cc_availability = "SINGLE_ZONE"
```
This example provide two ways to execute the terraform scripts:

### GitHub Action Workflow

Once you fork or upload a copy of this repo to your own GitHub organization you will be able to create the proper repository secrets to be able to execute the terraform scripts.

To do so you just need to go to `actions -> Kafka Cluster Management (on workflows) -> Run Workflow`

Then you will have to options for the action to perform:

- `create`: Will apply the `main.tf` and execute the execute the actions needed to apply the changes between the `terraform state` and the changes proposed via `terraform vars`, so in resume will create or destroy any resource you configure via terraform vars.
- `destroy`: Will destroy any resource managed and stored on the current `terraform state`

### From terminal

It is possible to execute the terraform scripts directly from a terminal (remember that to execute some parts of the script the host of the terraform scripts need access to confluent cloud data plane and this case that means that need to have access via private link).

To do so from the `private-link/confluent` folder we execute:

```bash
terraform init --upgrade
```

To initialize terraform providers and modules

```bash
terraform plan --out tf.plan
```

Plan phase of the terraform scripts that will give us a list of the to be executed actions and store it on the `tf.plan` file

```bash
terraform apply tf.plan
```

execute the plan.
