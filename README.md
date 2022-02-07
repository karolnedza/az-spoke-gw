# az-spoke-gw example 


module "az-spoke1-west-europe" {

    source  = "./avx-azure-spoke"
  
    region                = "Central US"
  

    resource_group   = "rg-spoke-1"
  

    account               = "az-spoke-1"
  
    vnet_cidr             = "10.11.0.0/23"
  

    gw_name               = "az-spoke1-west-eu"
  
    vnet_name             = "az-spoke-1-vnet"


    gw_subnet_cidr           = "10.11.0.0/28"
  
    gw_subnet_cidr_hagw      = "10.11.0.16/28"
  

    subnet_vm1          = "10.11.0.32/28"   # here VM lives
  
    subnet_vm2          = "10.11.0.64/28"   # here VM lives
  

    transit_gw           = "transit-gw" # optional
  
    security_domain      = "red"        # optional 
 
  
}


