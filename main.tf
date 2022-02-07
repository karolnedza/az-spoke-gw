# Resource Group for Spoke Vnet and AVX Spoke GW
resource "azurerm_resource_group" "avx-spoke-rg" {
  name     = var.resource_group
  location = var.region
}


# Vnet for Spoke Vnet and AVX Spoke GW
resource "azurerm_virtual_network" "avx-spoke-vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.avx-spoke-rg.location
  resource_group_name = azurerm_resource_group.avx-spoke-rg.name
  address_space       = [var.vnet_cidr]
}


# Public Subnet for AVX Spoke GW. Please use subnet length /26 - /28

resource "azurerm_subnet" "avx-gateway-subnet" {
  name                 = "avx-gateway-subnet"
  resource_group_name  = azurerm_resource_group.avx-spoke-rg.name
  virtual_network_name = azurerm_virtual_network.avx-spoke-vnet.name
  address_prefixes     = [var.gw_subnet_cidr]
}

resource "azurerm_subnet" "avx-gateway-subnet-hagw" {
  name                 = "avx-gateway-subnet-hagw"
  resource_group_name  = azurerm_resource_group.avx-spoke-rg.name
  virtual_network_name = azurerm_virtual_network.avx-spoke-vnet.name
  address_prefixes     = [var.gw_subnet_cidr_hagw]
}

# Public Subnets for VM instances

resource "azurerm_subnet" "avx-subnet-vm1" {
  name                 = "az-subnet-vm1"
  resource_group_name  = azurerm_resource_group.avx-spoke-rg.name
  virtual_network_name = azurerm_virtual_network.avx-spoke-vnet.name
  address_prefixes     = [var.subnet_vm1]
}

resource "azurerm_subnet" "avx-subnet-vm2" {
  name                 = "az-subnet-vm2"
  resource_group_name  = azurerm_resource_group.avx-spoke-rg.name
  virtual_network_name = azurerm_virtual_network.avx-spoke-vnet.name
  address_prefixes     = [var.subnet_vm2]
}


### Route tables for VM instances RT1(GW) and RT2(GW-HAGW)
#
resource "azurerm_route_table" "vm-azure-rt1" {
  name                = "${var.vnet_name}-rt1"

  location            = azurerm_resource_group.avx-spoke-rg.location
  resource_group_name = azurerm_resource_group.avx-spoke-rg.name

  route {
    name                   = "blackhole"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "None"  # this is required for Central Egress
  }

  lifecycle {  # AVX Controller adds routes
  ignore_changes = [route]
  }
}

resource "azurerm_route_table" "vm-azure-rt2" {
  name                = "${var.vnet_name}-rt2"
  location            = azurerm_resource_group.avx-spoke-rg.location
  resource_group_name = azurerm_resource_group.avx-spoke-rg.name

lifecycle { # AVX Controller adds routes
 ignore_changes = [route]
  }
}

### Route table to subnet association

resource "azurerm_subnet_route_table_association" "subnet-vm1-to-rt1" {
  subnet_id      = azurerm_subnet.avx-subnet-vm1.id
  route_table_id = azurerm_route_table.vm-azure-rt1.id
}

resource "azurerm_subnet_route_table_association" "subnet-vm2-to-rt2" {
  subnet_id      = azurerm_subnet.avx-subnet-vm2.id
  route_table_id = azurerm_route_table.vm-azure-rt2.id
}

# Aviatrix Spoke GW

resource "aviatrix_spoke_gateway" "avx-spoke-gw" {
cloud_type                        = 8
account_name                      = var.account
gw_name                           = var.gw_name
vpc_id                            = "${azurerm_virtual_network.avx-spoke-vnet.name}:${azurerm_resource_group.avx-spoke-rg.name}"
vpc_reg                           = var.region
gw_size                           = var.instance_size
ha_gw_size                        = var.ha_gw ? var.instance_size : null
subnet                            = azurerm_subnet.avx-gateway-subnet.address_prefixes[0]
ha_subnet                         = var.ha_gw ? azurerm_subnet.avx-gateway-subnet-hagw.address_prefixes[0] : null
insane_mode                       = var.insane_mode
enable_active_mesh                = var.active_mesh
manage_transit_gateway_attachment = false
single_az_ha                      = var.single_az_ha
single_ip_snat                    = var.single_ip_snat
customized_spoke_vpc_routes       = var.customized_spoke_vpc_routes
filtered_spoke_vpc_routes         = var.filtered_spoke_vpc_routes
included_advertised_spoke_routes  = var.included_advertised_spoke_routes
zone                     = var.ha_gw ? (var.single_az_ha ? null : "az-1") : null
ha_zone                  = var.ha_gw ? (var.single_az_ha ? null : "az-2") : null
}

#### Spoke Attachment to Transit

resource "aviatrix_spoke_transit_attachment" "avx-spoke-gw-att" {
  spoke_gw_name   = aviatrix_spoke_gateway.avx-spoke-gw.gw_name
  transit_gw_name = var.transit_gw
  depends_on = [azurerm_subnet_route_table_association.subnet-vm1-to-rt1, azurerm_subnet_route_table_association.subnet-vm2-to-rt2] # Create Spoke attachment AFTER route table associations

}


### Security Domain Association

resource "aviatrix_segmentation_security_domain_association" "spoke-security-domain" {
  count =  var.security_domain == "" ? 0 : 1
  transit_gateway_name = var.transit_gw
  security_domain_name = var.security_domain
  attachment_name      = aviatrix_spoke_gateway.avx-spoke-gw.gw_name
  depends_on           = [aviatrix_spoke_transit_attachment.avx-spoke-gw-att] # create  security association after spoke attachment
}
