##
# Variables
##

##
# Common Variables
##

##
# DNS Variables
##

variable "ttl_setting" {
  description = "The TTL setting for the DNS records"
  type        = number
  default     = 3600
}

##
# Email Communication Variables
##

variable "data_location" {
  description = "The location of the email data."
  type        = string
  default     = "UK"
}

variable "custom_domain" {
  description = "The custom domain for the email communication service"
  type        = string
  default     = "domainname.com"
}

