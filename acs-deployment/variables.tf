##
# Variables
##

##
# Common Variables
##
variable "tag_environment" {
  type    = string
  default = "Testing"
}

variable "tag_project" {
  type    = string
  default = "AzureCommunicationServices"
}

variable "tag_creator" {
  type    = string
  default = "TechieLass"
}


##
# Domain Variables
##

variable "ttl_setting" {
  description = "The TTL setting for the DNS records"
  type        = number
  default     = 3600
}

variable "custom_domain" {
  description = "The custom domain for the email communication service"
  type        = string
  default     = "techielass.com"
}

variable "custom_domain_rg" {
  description = "The resource group for the custom domain"
  type        = string
  default     = "rg-lzpt"
}

##
#  Communication Variables
##

variable "acs_name" {
  description = "Name of the ACS service to be deployed."
  type        = string
  default     = "techielass-acs"
}

variable "data_location" {
  description = "The location of the email data."
  type        = string
  default     = "UK" # Or use Africa, Asia Pacific, Australia, Brazil, Canada, Europe, France, Germany, India, Japan, Korea, Norway, Switzerland, UAE, UK, usgov or United States as needed. 
}


