terraform {
  required_version = ">= 0.13.0"
  required_providers {
    azurerm  = ">= 2.7.0"
    template = "~> 2.1"
    random   = ">= 2"
  }
}