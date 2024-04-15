# Cluster Dedicado en Azure Private Link

[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/ogomezso/confluent-terraform-azure-playground/blob/main/private-link/README.md)
[![es](https://img.shields.io/badge/lang-es-yellow.svg)](https://github.com/ogomezso/confluent-terraform-azure-playground/blob/main/private-link/README.es.md)


En este ejemplo usaremos los Providers Terraform de  [Confluent's](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs) y [Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) para crear:

- Confluent Cloud Environment
- Confluent Cloud Schema Registry
- Confluent Cloud Azure Private Network securizada con Private Link
- Confluent Cloud Private Link Access
- Confluent Cloud Kafka Cluster
- Confluent Cloud Service Account (Cluster Admin)
- Azure Private DNS Hosted Zone
- Azure Private Endpoints
- Azure Virtual Network Links para la Hosted Zone
- Azure DNS Records tanto para la HZ como para cada Zona

> Este es el minimo de recursos que recomendamos manejar a través del estado terraform pero se debe tener en cuenta que cualquier de ellos puede bien, pre crearse y sustituirse por el correspondiente recurso tipo data o crearse a posteriori

## Prerequisitos

De manera general recordamos que para la ejecución de ciertas acciones incluidas en el ejemplo necesitamos accesos al Control Plane de Confluent Cloud (setup de service Accounts, creación de Role Bindings), esto implica que, puesto que correremos el cluster en un red securizada con Private Link, los scripts deben ejecutarse desde un host que permita el acceso a dichos private links (tipicamente una maquina en la misma VNET linkada con la red Confluent)

Para este ejemplo:

### Azure

Este ejemplo ** creará algunos recursos sobre un resource group y VNET azure existentes **

Estos recursos se configuran via variables terraform ( `terraform.tfvars`), sirva de ejemplo:

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

Para ejecutar la creación de recursos en Confluent Cloud necesitaremos una [Confluent Cloud API Key](https://docs.confluent.io/cloud/current/access-management/authenticate/api-keys/api-keys.html?_ga=2.231529055.1958880784.1713172368-1450644743.1702551086&_gac=1.81281381.1711472085.CjwKCAjw5ImwBhBtEiwAFHDZx9ECrTVq-WTKbclHtPX2nUzZ6700UVxHeaOnCV7XOxDXs2ZrM7Mi7hoCe8YQAvD_BwE&_gl=1*mizv6d*_ga*MTQ1MDY0NDc0My4xNzAyNTUxMDg2*_ga_D2D3EGKSGD*MTcxMzE3MjM2OC42NDIuMC4xNzEzMTcyMzY4LjYwLjAuMA..#cloud-cloud-api-keys) Global.

La mejor manera de pasar estas credenciales es via variable de entorno

```text
CONFLUENT_CLOUD_API_KEY=<your_api_key>
CONFLUENT_CLOUD_API_SECRET=<your_api_secret>
```
En el caso de que estes usando lq `github action` propuesta por el ejemplo necesitaras ademas crear un secreto en el repositorio especifico, para distinguirlo de la variable de entorno usada por el provider terraform el workflow del ejemplo usa estos nombres:

```text
CCLOUD_API_KEY=<your_api_key>
CCLOUD_API_SECRET=<your_api_secret> 
```

### GitHub Action

En el directorio `.github/workflows` encontraras el código de la `GitHub Action` con la capacidad de crear y destruir clusters:

Debemos tener en cuenta algunas consideraciones

#### Action Runner

Como hemos visto en los prerequisitos generales necesitamos que el script se ejecute en una máquina con unas condiciones especiales para lo que usaremos un `self-host action runner` despleagado en la VNET linkada con la  Confluent Cloud Network. Puedes encontrar información de como hacerlo en esta [guia](https://www.cloudwithchris.com/blog/github-selfhosted-runner-on-azure/).

#### Terraform Backend

Por otro lado para poder mantener un estado consistente terraform necesita almacenar su `terraform state` en algún lugar accessible para la siguiente ejecución del workflow, para este escenario usamos `azure blob storage container` como backend.

Puedes encontrar mas información [aquí](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli).

El uso de este mecanismo se configura en el fichero `backend.tf`:

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

Para este ejemplo usamos autenticaón basica por id y secreto que seteamos en  [Github Actions Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) y que se referecian en el env del workflow de la siguiente manera:

````yaml
ARM_CLIENT_ID: ${{ secrets.AZ_CLIENT_ID }}
ARM_CLIENT_SECRET: ${{ secrets.AZ_CLIENT_SECRET }}
ARM_SUBSCRIPTION_ID: ${{ secrets.AZ_SUBSCRIPTION_ID }}
ARM_TENANT_ID: ${{ secrets.AZ_TENANT_ID }}
````

## Running

Una vez tenemos todos los prerequisitos solo queda configurar nuestro entorno mediante variables teerraform en el fichero `terraform.tfvars`.

Este repositorio provee una fichero de ejemplo:

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
Para este escenario existen dos maneras de ejecutar los script terraform

### GitHub Action Workflow

Necesitarás un fork o subir este repositorio a tu propia organización guthub para poder configurar tus propios secretos, Una vez hecho esto solo tendras que ejecurar el workflow `Kafka Cluster Management`

Navengando a `actions -> Kafka Cluster Management (on workflows) -> Run Workflow`

Una vez pulsado el botón `Run Workflow` apareceran dos posibles acciones:

- `create`: Aplica el  `main.tf` y ejecuta las acciones necesarias para realizar los posibles cambios entre lo descrito en el  `terraform vars` y el estado guardado en el `terraform state`.
- 
- `destroy`: Destrurirá todos los recursos manejado y persistidos actualmente en el  `terraform state`

### desde terminal

Es posible ejecutar todos los scripts directamente desde un terminal con terraform disponible (tenga en cuenta que tal como hemos hablado anteriormente el host debe tener acceso al Control Plane de su cluster).

Desde la carpeta `private-link/confluent` ejecute:

```bash
terraform init --upgrade
```

Para inicializar los providers y módulos terraform

```bash
terraform plan --out tf.plan
```

Fase de Plan en la que terraform nos da una lista de las acciones a ejecutar y las persiste en el fichero `tf.plan`

```bash
terraform apply tf.plan
```
 ejecución del plan.
