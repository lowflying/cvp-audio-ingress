provider "azurerm" {
  version = ">= 2.7.0"
  features {}
}

provider "azurerm" {
  alias           = "secops"
  subscription_id = var.ws_sub_id
  version         = ">= 2.7.0"
  features {}
}