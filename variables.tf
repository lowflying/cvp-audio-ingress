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

variable "dns_tenant_id" {
  type = string
}

variable "dns_client_id" {
  type = string
}

variable "dns_client_secret" {
  type = string
}

variable "dns_subscription_id" {
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