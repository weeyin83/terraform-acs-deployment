
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

resource "azurerm_communication_service" "acs" {
  name                = var.acs_name
  resource_group_name = azurerm_resource_group.rg.name
  data_location       = var.data_location
}

resource "azurerm_email_communication_service" "acsemail" {
  name                = "${module.naming.resource_group.name_unique}-email"
  resource_group_name = azurerm_resource_group.rg.name
  data_location       = var.data_location
}

resource "azurerm_email_communication_service_domain" "acsdomain" {
  name             = var.custom_domain
  email_service_id = azurerm_email_communication_service.acsemail.id

  domain_management = "CustomerManaged"
}

# Create a TXT record for domain verification in the DNS zone
resource "azurerm_dns_txt_record" "domain" {
  count               = 1
  name                = "@"
  zone_name           = var.custom_domain
  resource_group_name = var.custom_domain_rg
  ttl                 = var.ttl_setting

  # Add the TXT record for domain verification
  record {
    value = element(azurerm_email_communication_service_domain.acsdomain.verification_records[0].domain[*].value, count.index)
  }

  # Add record for SPF Verification
  record {
    value = element(azurerm_email_communication_service_domain.acsdomain.verification_records[0].spf[*].value, count.index)
  }

  # Ensure the ACS Email service & Azure DNS serviec has been deployed before creating these records
  depends_on = [azurerm_email_communication_service_domain.acsdomain]
}

# Create a CNAME record for DKIM verification in the DNS zone
resource "azurerm_dns_cname_record" "dkim" {
  count               = 1
  name                = element(azurerm_email_communication_service_domain.acsdomain.verification_records[0].dkim[*].name, count.index)
  zone_name           = var.custom_domain
  resource_group_name = var.custom_domain_rg
  ttl                 = element(azurerm_email_communication_service_domain.acsdomain.verification_records[0].dkim[*].ttl, count.index)
  record              = element(azurerm_email_communication_service_domain.acsdomain.verification_records[0].dkim[*].value, count.index)

  # Ensure the ACS Email service & Azure DNS serviec has been deployed before creating these records
  depends_on = [azurerm_email_communication_service_domain.acsdomain]
}

# Create a CNAME record for DKIM2 verification in the DNS zone
resource "azurerm_dns_cname_record" "dkim2" {
  count               = 1
  name                = element(azurerm_email_communication_service_domain.acsdomain.verification_records[0].dkim2[*].name, count.index)
  zone_name           = var.custom_domain
  resource_group_name = var.custom_domain_rg
  ttl                 = element(azurerm_email_communication_service_domain.acsdomain.verification_records[0].dkim2[*].ttl, count.index)
  record              = element(azurerm_email_communication_service_domain.acsdomain.verification_records[0].dkim2[*].value, count.index)

  # Ensure the ACS Email service & Azure DNS serviec has been deployed before creating these records
  depends_on = [azurerm_email_communication_service_domain.acsdomain]
}

# Initiate Domain Verification
# API: https://learn.microsoft.com/en-us/rest/api/communication/resourcemanager/domains/initiate-verification?view=rest-communication-resourcemanager-2023-03-31&tabs=HTTP
resource "azapi_resource_action" "validate_domain" {
  count       = 1
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  action      = "initiateVerification"
  resource_id = azurerm_email_communication_service_domain.acsdomain.id

  body = {
    verificationType = "Domain" # or use "SPF", "DKIM", "DMARC", "DKIM2" as needed
  }
  depends_on = [azurerm_dns_txt_record.domain]
}

# Initiate SPF Verification
# API: https://learn.microsoft.com/en-us/rest/api/communication/resourcemanager/domains/initiate-verification?view=rest-communication-resourcemanager-2023-03-31&tabs=HTTP
resource "azapi_resource_action" "validate_spf" {
  count       = 1
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  action      = "initiateVerification"
  resource_id = azurerm_email_communication_service_domain.acsdomain.id

  body = {
    verificationType = "SPF" # or use "SPF", "DKIM", "DMARC", "DKIM2" as needed
  }
  depends_on = [azapi_resource_action.validate_domain]
}

# Initiate DKIM Verification
# API: https://learn.microsoft.com/en-us/rest/api/communication/resourcemanager/domains/initiate-verification?view=rest-communication-resourcemanager-2023-03-31&tabs=HTTP
resource "azapi_resource_action" "validate_dkim" {
  count       = 1
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  action      = "initiateVerification"
  resource_id = azurerm_email_communication_service_domain.acsdomain.id

  body = {
    verificationType = "DKIM" # or use "SPF", "DKIM", "DMARC", "DKIM2" as needed
  }
  depends_on = [azapi_resource_action.validate_spf]
}

# Initiate DKIM2 Verification
# API: https://learn.microsoft.com/en-us/rest/api/communication/resourcemanager/domains/initiate-verification?view=rest-communication-resourcemanager-2023-03-31&tabs=HTTP
resource "azapi_resource_action" "validate_dkim2" {
  count       = 1
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  action      = "initiateVerification"
  resource_id = azurerm_email_communication_service_domain.acsdomain.id

  body = {
    verificationType = "DKIM2" # or use "SPF", "DKIM", "DMARC", "DKIM2" as needed
  }
  depends_on = [azapi_resource_action.validate_dkim]
}

# Association of the Email Domain with the Communication Service
resource "azurerm_communication_service_email_domain_association" "email_domain_association" {
  communication_service_id = azurerm_communication_service.acs.id
  email_service_domain_id  = azurerm_email_communication_service_domain.acsdomain.id
  depends_on               = [azapi_resource_action.validate_dkim2]
}
