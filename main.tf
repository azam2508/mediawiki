module "aks-cluster" {
    source = "./aks-cluster"
    acr-name = "mwikiacr"
    aks-name = "mwiki-aks"
}


// Using backend with the Azure CLI or service principal 
terraform {
  backend "azurerm" {
    resource_group_name = "mwiki-rg"
    storage_account_name = "mwikistorageaccount"
    container_name       = "mwiki-terraform-state"
    key                  = "mwiki.terraform.tfstate"
    }
}