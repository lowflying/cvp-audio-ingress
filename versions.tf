terraform {
  backend "azurerm" {
  }

  required_version = ">= 0.13"
  required_providers {
    azurerm = ">= 2.10.0"
  }
}
