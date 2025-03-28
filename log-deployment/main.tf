##
# Terraform Configuration
##

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71, < 5.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.2.0, < 3.0.0"
    }
  }
}

provider "azapi" {
  # Configuration options
}

provider "azurerm" {
  features {}
  subscription_id = "xxx-xxx-xxx-xxx"
}

##
# Variables
##

variable "log_analytics_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "la-acs"
}

variable "log_analytics_rg" {
  description = "Name of the resource group where the Log Analytics workpsace is hosted"
  type        = string
  default     = "observability"
}

variable "diagnostic_name" {
  description = "Name of the diagnostic settings"
  type        = string
  default     = "acs-logs"
}

variable "azure_communications_services_name" {
  description = "Name of the Azure Communication Services deployed"
  type        = string
  default     = ""
}

variable "azure_communications_services_rg" {
  description = "Name of the resource group where the Azure Communication Services is deployed"
  type        = string
  default     = ""
}

data "azurerm_log_analytics_workspace" "observability_log_analytics_workspace" {
  name                = var.log_analytics_name
  resource_group_name = var.log_analytics_rg
}

data "azurerm_communication_service" "acs" {
  name                = var.azure_communications_services_name
  resource_group_name = var.azure_communications_services_rg
}

# Turn on logs being sent to a Log Analytics Workspace
resource "azurerm_monitor_diagnostic_setting" "acs-logs" {
  name                           = var.diagnostic_name
  target_resource_id             = data.azurerm_communication_service.acs
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.observability_log_analytics_workspace.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "EmailSendMailOperational"
  }

  enabled_log {
    category = "Usage"
  }

  enabled_log {
    category = "EmailStatusUpdateOperational"
  }

  enabled_log {
    category = "EmailUserEngagementOperational"
  }

  metric {
    category = "AllMetrics"
  }
}
