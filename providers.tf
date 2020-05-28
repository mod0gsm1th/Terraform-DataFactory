#Terraform version
###
#terraform {
#	required_version = "> 0.12.6"
#	required_providers {
#	  azurerm = "1.44.0"
#}
#}
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}

    subscription_id = "0b97f93e-03fa-49ab-a749-a10c33756e8e"
	client_id = "1a724262-f67f-47c0-8e7b-e2c4cc6ee02b"
	client_secret = "88bed221-c527-40b5-a90a-3968e0466be3"
	tenant_id = "59783927-d29f-4be3-aa7b-29aaf737b343"
}

