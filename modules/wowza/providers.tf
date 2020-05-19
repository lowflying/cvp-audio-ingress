provider "azurerm" {
  version = ">= 2.7.0"
  features {}
}

provider "azurerm" {
  alias           = "secops"
  subscription_id = "8999dec3-0104-4a27-94ee-6588559729d1"
  version         = ">= 2.7.0"
  features {}
}