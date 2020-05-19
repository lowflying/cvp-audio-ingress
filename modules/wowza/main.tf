locals {
  service_name  = "${var.product}-recordings-${var.env}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.service_name}-rg"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_storage_account" "sa" {
  name                = "${replace(lower(local.service_name), "-", "")}sa"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.common_tags
  access_tier               = var.sa_access_tier
  account_kind              = var.sa_account_kind
  account_tier              = var.sa_account_tier
  account_replication_type  = var.sa_account_replication_type
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "media_container_01" {
  name                  = "recordings01"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "media_container_02" {
  name                  = "recordings02"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_virtual_network" "vnet" {
  name          = "${local.service_name}-vnet"
  address_space = [var.address_space]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "sn" {
  name                 = "wowza"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.address_space
  service_endpoints    = ["Microsoft.KeyVault"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "endpoint" {
  name = "${azurerm_storage_account.sa.name}-endpoint"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  subnet_id = azurerm_subnet.sn.id

  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-scon"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["Blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = true
}

resource "azurerm_private_dns_a_record" "sa_a_record" {
  name                = azurerm_storage_account.sa.name
  zone_name           = azurerm_private_dns_zone.blob.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
}

# resource "azurerm_storage_account_network_rules" "wowza" {
#   resource_group_name  = azurerm_resource_group.rg.name
#   storage_account_name = azurerm_storage_account.sa.name

#   default_action             = "Deny"
#   ip_rules                   = []
#   virtual_network_subnet_ids = []
#   bypass                     = ["Logging", "AzureServices"]
# }

resource "azurerm_public_ip" "pip" {
  name = "${local.service_name}-pip"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_public_ip" "pip_vm1" {
  name = "${local.service_name}-pipvm1"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_public_ip" "pip_vm2" {
  name = "${local.service_name}-pipvm2"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_network_security_group" "sg" {
  name = "${local.service_name}-sg"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule {
    name                       = "RTMPS"
    priority                   = 1040
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.rtmps_source_address_prefixes
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic1" {
  name = "${local.service_name}-nic1"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "wowzaConfiguration"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_vm1.id
  }
}

resource "azurerm_network_interface" "nic2" {
  name = "${local.service_name}-nic2"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "wowzaConfiguration"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_vm2.id
  }
}

resource "azurerm_lb" "lb" {
  name                = "${local.service_name}-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "be_add_pool" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "wowza-running-probe"
  port                = 443
  protocol            = "Tcp"
}

resource "azurerm_lb_rule" "rtmps_lb_rule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "RTMPS"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration.0.name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.be_add_pool.id
  probe_id                       = azurerm_lb_probe.lb_probe.id
  load_distribution              = "SourceIPProtocol"
  idle_timeout_in_minutes        = 30
}

resource "azurerm_network_interface_security_group_association" "sg_assoc1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_network_interface_security_group_association" "sg_assoc2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_subnet_network_security_group_association" "sg_assoc_subnet" {
  subnet_id                 = azurerm_subnet.sn.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_network_interface_backend_address_pool_association" "be_add_pool_assoc_vm1" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = azurerm_network_interface.nic1.ip_configuration.0.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.be_add_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "be_add_pool_assoc_vm2" {
  network_interface_id    = azurerm_network_interface.nic2.id
  ip_configuration_name   = azurerm_network_interface.nic2.ip_configuration.0.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.be_add_pool.id
}

resource "random_password" "certPassword" {
  length           = 32
  special          = true
  override_special = "_%*"
}

resource "random_password" "restPassword" {
  length           = 32
  special          = true
  override_special = "_%*"
}

resource "random_password" "streamPassword" {
  length           = 32
  special          = true
  override_special = "_%*"
}

data "template_file" "cloudconfig1" {
  template = file(var.cloud_init_file)
  vars = {
    certPassword       = random_password.certPassword.result
    certThumbprint     = var.thumbprint
    storageAccountName = azurerm_storage_account.sa.name
    storageAccountKey  = azurerm_storage_account.sa.primary_access_key
    restPassword       = md5("wowza:Wowza:${random_password.restPassword.result}")
    streamPassword     = md5("wowza:Wowza:${random_password.streamPassword.result}")
    containerName      = azurerm_storage_container.media_container_01.name
    numApplications    = var.num_applications
  }
}

data "template_file" "cloudconfig2" {
  template = file(var.cloud_init_file)
  vars = {
    certPassword       = random_password.certPassword.result
    certThumbprint     = var.thumbprint
    storageAccountName = azurerm_storage_account.sa.name
    storageAccountKey  = azurerm_storage_account.sa.primary_access_key
    restPassword       = md5("wowza:Wowza:${random_password.restPassword.result}")
    streamPassword     = md5("wowza:Wowza:${random_password.streamPassword.result}")
    containerName      = azurerm_storage_container.media_container_02.name
    numApplications    = var.num_applications
  }
}

data "template_cloudinit_config" "wowza_setup1" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudconfig2.rendered
  }
}

data "template_cloudinit_config" "wowza_setup2" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudconfig2.rendered
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name = "${local.service_name}-vm1"

  depends_on = [
    azurerm_private_dns_a_record.sa_a_record,
    azurerm_private_dns_zone_virtual_network_link.vnet_link
  ]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  size           = var.vm_size
  admin_username = var.admin_user
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  provision_vm_agent = true
  secret {
    certificate {
      url = var.service_certificate_kv_url
    }
    key_vault_id = var.key_vault_id
  }

  custom_data = data.template_cloudinit_config.wowza_setup1.rendered

  source_image_reference {
    publisher = var.wowza_publisher
    offer     = var.wowza_offer
    sku       = var.wowza_sku
    version   = var.wowza_version
  }

  plan {
    name      = var.wowza_sku
    product   = var.wowza_offer
    publisher = var.wowza_publisher
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name = "${local.service_name}-vm2"

  depends_on = [
    azurerm_private_dns_a_record.sa_a_record,
    azurerm_private_dns_zone_virtual_network_link.vnet_link
  ]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  size           = var.vm_size
  admin_username = var.admin_user
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  provision_vm_agent = true
  secret {
    certificate {
      url = var.service_certificate_kv_url
    }
    key_vault_id = var.key_vault_id
  }

  custom_data = data.template_cloudinit_config.wowza_setup2.rendered

  source_image_reference {
    publisher = var.wowza_publisher
    offer     = var.wowza_offer
    sku       = var.wowza_sku
    version   = var.wowza_version
  }

  plan {
    name      = var.wowza_sku
    product   = var.wowza_offer
    publisher = var.wowza_publisher
  }

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_log_analytics_workspace" "log_analytics" {
  name                = var.ws_name
  resource_group_name = var.ws_rg
  provider            = azurerm.secops
}

resource "azurerm_virtual_machine_extension" "log_analytics_vm1" {
  name                 = "${local.service_name}-vm1-ext"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm1.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.7"

  settings = <<SETTINGS
    {
        "workspaceId": "${data.azurerm_log_analytics_workspace.log_analytics.workspace_id}"
    }
SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
    {
        "workspaceKey": "${data.azurerm_log_analytics_workspace.log_analytics.primary_shared_key}"
    }
PROTECTEDSETTINGS

}

resource "azurerm_virtual_machine_extension" "log_analytics_vm2" {
  name                 = "${local.service_name}-vm2-ext"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm2.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.7"

  settings = <<SETTINGS
    {
        "workspaceId": "${data.azurerm_log_analytics_workspace.log_analytics.workspace_id}"
    }
SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
    {
        "workspaceKey": "${data.azurerm_log_analytics_workspace.log_analytics.primary_shared_key}"
    }
PROTECTEDSETTINGS

}
