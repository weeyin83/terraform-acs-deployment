
# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

locals {
  azure_regions = [
    "ukwest",
    "westeurope",
    "francecentral",
    "swedencentral"
    # Add other regions as needed
  ]
}

# This picks a random region from the list of regions.
resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

# This is required for resource modules
resource "azurerm_resource_group" "rg" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique

  tags = {
    Environment = var.tag_environment
    Project     = var.tag_project
    Creator     = var.tag_creator
  }
}


module "avm-res-network-dnszone" {
  source              = "Azure/avm-res-network-dnszone/azurerm"
  version             = "0.1.0"
  name                = var.custom_domain
  resource_group_name = azurerm_resource_group.rg.name
}
