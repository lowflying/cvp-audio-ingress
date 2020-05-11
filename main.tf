locals {
  rg_name          = "${var.product}-media-service-${var.env}"
  sa_name          = "${var.product}mediaservice${var.env}"
  service_name     = "${var.product}mediaservice${var.env}"
  num_applications = 9
}

module "wowza" {
  source                     = "./modules/wowza"
  location                   = var.location
  product                    = var.product
  env                        = var.env
  common_tags                = var.common_tags
  admin_ssh_key_path         = var.admin_ssh_key_path
  service_certificate_kv_url = var.service_certificate_kv_url
  key_vault_id               = var.key_vault_id
  address_space              = var.address_space
  num_applications           = local.num_applications
  cert_path                  = var.cert_path
  thumbprint                 = var.thumbprint
}

resource "azurerm_dns_a_record" "wowza" {
  //  provider = azurerm.dns

  name                = "${var.product}-media-service-${var.env}"
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_resource_group
  ttl                 = 300
  records             = [module.wowza.public_ip_address]
}
