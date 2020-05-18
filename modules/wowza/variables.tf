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

variable "sa_access_tier" {
  type    = string
  default = "Cool"
}
variable "sa_account_kind" {
  type    = string
  default = "BlobStorage"
}
variable "sa_account_tier" {
  type    = string
  default = "Standard"
}
variable "sa_account_replication_type" {
  type    = string
  default = "RAGRS"
}

variable "address_space" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vm_size" {
  type    = string
  default = "Standard_F8s_v2"
}

variable "admin_user" {
  type    = string
  default = "wowza"
}

variable "admin_ssh_key_path" {
  type    = string
  default = "~/.ssh/wowza.pub"
}

variable "os_disk_type" {
  type    = string
  default = "Premium_LRS"
}

variable "service_certificate_kv_url" {
  type = string
}

variable "cert_path" {
  type = string
}

variable "thumbprint" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "cloud_init_file" {
  description = "The location of the cloud init configuration file."
  type        = string
  default     = "./cloudconfig.tpl"
}

variable "num_applications" {
  type    = number
  default = 0
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
  type = string
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
  type    = string
  default = "hmcts-prod"
}

variable "ws_rg" {
  type    = string
  default = "oms-automation"
}