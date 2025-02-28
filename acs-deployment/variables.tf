
##
# Variables
##

##
# Common Variables
##

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
  default     = "domain.com"
}

variable "custom_domain_rg" {
  description = "The resource group for the custom domain"
  type        = string
  default     = "resrouce group name"
}

##
#  Communication Variables
##

variable "acs_name" {
  description = "Name of the ACS service to be deployed."
  type        = string
  default     = "acsname"
}

variable "data_location" {
  description = "The location of the email data."
  type        = string
  default     = "UK" # Or use Africa, Asia Pacific, Australia, Brazil, Canada, Europe, France, Germany, India, Japan, Korea, Norway, Switzerland, UAE, UK, usgov or United States as needed. 
}



