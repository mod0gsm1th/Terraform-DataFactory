##### This terraform creates resource group, vnet, data factory and linked service SQL server  ###### 
#####     #######

resource "azurerm_resource_group" "MDSDATAFAC" {
  name     = "mdsdatafactory"
  location = "east us"
}

resource "azurerm_virtual_network" "MDSDFVET" {
  name                = "mdsdfvnet"
  location            = azurerm_resource_group.MDSDATAFAC.location
  resource_group_name = azurerm_resource_group.MDSDATAFAC.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "MDSDF_subnet" {
  name                 = "datafacsubnet" 
  resource_group_name  = azurerm_resource_group.MDSDATAFAC.name
  virtual_network_name = azurerm_virtual_network.MDSDFVET.name
  address_prefix       = "10.0.1.0/24"
}
############################# create Data factory and Linked SQL server service  #######################
resource "azurerm_data_factory" "MDSDAFAC" {
  name                = "mdsdatafac"
  location            = azurerm_resource_group.MDSDATAFAC.location
  resource_group_name = azurerm_resource_group.MDSDATAFAC.name
}

resource "azurerm_data_factory_linked_service_sql_server" "MDSDAFACLSSIS" {
  name                = "mdsdflinkedssis"
  resource_group_name = azurerm_resource_group.MDSDATAFAC.name
  data_factory_name   = azurerm_data_factory.MDSDAFAC.name
  connection_string   = "Integrated Security=False;Data Source=test;Initial Catalog=test;User ID=test;Password=test"
}
############################# create storage for batch processing and Batch processing account  ##############
resource "azurerm_storage_account" "MDSBatch" {
  name                     = "mdsbatchstorage"
  resource_group_name      = azurerm_resource_group.MDSDATAFAC.name
  location                 = azurerm_resource_group.MDSDATAFAC.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "MDSBatchACCT" {
  name                 = "mdsbatchaccount"
  resource_group_name  = azurerm_resource_group.MDSDATAFAC.name
  location             = azurerm_resource_group.MDSDATAFAC.location
  pool_allocation_mode = "BatchService"
  storage_account_id   = azurerm_storage_account.MDSBatch.id

  tags = {
    environment = "test"
  }
}
################################# create Data lake storage gen 2 ####################
resource "azurerm_data_lake_store" "MDSDataLS" {
  name                = "mdsconsumptiondatalake"
  resource_group_name = azurerm_resource_group.MDSDATAFAC.name
  location            = "eastus2"
  #### this storage type is not available in east us or west us  #######
  encryption_state    = "Enabled"
  encryption_type     = "ServiceManaged"
}
################################ create SQL instance    ##################################
resource "azurerm_sql_server" "MDSDFSQL" {
  name                         = "mdsdfmysqlserver"
  resource_group_name          = azurerm_resource_group.MDSDATAFAC.name
  #location             1       = "West US"
  location                     = azurerm_resource_group.MDSDATAFAC.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
    environment = "test"
  }
}
################################### SQL storage account  ########################
resource "azurerm_storage_account" "MDSSQLSTORACCT" {
  name                     = "mdssqlacct"
  resource_group_name      = azurerm_resource_group.MDSDATAFAC.name
  location                 = azurerm_resource_group.MDSDATAFAC.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "MDSDB" {
  name                = "mdssqldatabase"
  resource_group_name = azurerm_resource_group.MDSDATAFAC.name
  location            = azurerm_resource_group.MDSDATAFAC.location
  #location            = "West US"
  server_name         = azurerm_sql_server.MDSDFSQL.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.MDSSQLSTORACCT.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.MDSSQLSTORACCT.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

  tags = {
    environment = "test"
  }
}
