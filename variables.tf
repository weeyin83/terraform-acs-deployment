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
  default     = "UK" # Or use Africa, Asia Pacific, Australia, Brazil, Canada, Europe, France, Germany, India, Japan, Korea, Norway, Switzerland, UAE, UK, usgov or United States as needed. 
}

variable "custom_domain" {
  description = "The custom domain for the email communication service"
  type        = string
  default     = "domainname.com"
}

