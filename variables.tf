variable "location" {
  type        = string
  description = "The azure resource location"
}

variable "env" {
  type        = string
  description = "The platform environment"
}

variable "common_tags" {
  type        = map(string)
  description = "Tags for the Azure resources"
}

variable "product" {
  type        = string
  description = "Product name used in naming standards"
}

variable "admin_ssh_key_path" {
  type    = string
  default = "~/.ssh/wowza.pub"
}

variable "service_certificate_kv_url" {
  type = string
}

variable "key_vault_id" {
  type = string
}

# DNS
variable "dns_zone_name" {
  type = string
}

variable "dns_resource_group" {
  type = string
}

variable "address_space" {
  type = string
}

variable "cert_path" {
  type = string
}

variable "thumbprint" {
  type = string
}

variable "wowza_publisher" {
  type = string
}

variable "wowza_offer" {
  type = string
}

variable "wowza_version" {
  type = string
}

variable "wowza_sku" {
  type    = string
  default = "linux-paid"
}

variable "num_applications" {
  type    = number
  default = 1
}

variable "ssh_public_key" {
  type = string
}

variable "rtmps_source_address_prefixes" {
  type = list(string)
}

variable "logging_enabled" {
  type    = bool
  default = false
}

variable "ws_name" {
  type = string
}

variable "ws_rg" {
  type    = string
  default = "oms-automation"
}

variable "ws_sub_id" {
  type = "string"
}