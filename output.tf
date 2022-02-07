output "vnet" {
  description = "The created VNET with all of it's attributes"
  value       = azurerm_virtual_network.avx-spoke-vnet
}

output "aviatrix_spoke_gateway" {
  description = "The Aviatrix spoke gateway object with all of it's attributes"
  value       = aviatrix_spoke_gateway.avx-spoke-gw
}

output "azure_rg" {
  description = "Azure resource group"
  value       = azurerm_resource_group.avx-spoke-rg
}


#
output "azure_rt1" {
  description = "Route Table 1"
  value = azurerm_route_table.vm-azure-rt1
}

output "azure_rt2" {
  description = "Route Table 2"
  value = azurerm_route_table.vm-azure-rt2
}
