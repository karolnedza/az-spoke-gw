variable "resource_group" {
  description = "The Azure Resource Group for Vnet and Spoke GW"
  type        = string
}

variable "region" {
  description = "The Azure region to deploy this module in"
  type        = string
}

variable "vnet_cidr" {
  description = "The CIDR range to be used for the VNET"
  type        = string
}

variable "gw_subnet_cidr" {
  description = "The CIDR range to be used for the AVX Spoke GW Public subnet"
  type        = string
}


variable "gw_subnet_cidr_hagw" {
  description = "The CIDR range to be used for the AVX Spoke GW-HA Public subnet"
  type        = string
}



variable "subnet_vm1" {
  description = "The CIDR range to be used for instances in subnet1"
  type        = string
}

variable "subnet_vm2" {
  description = "The CIDR range to be used for instances in subnet2"
  type        = string
}



variable "gw_name" {
  description = "Aviatrix Spoke GW Name"
  default = "az-spoke-gw"
}

variable "tgw_name" {
  description = "Aviatrix Transit GW Name"
  default = "az-transit-gw"
}

variable "vnet_name" {
  description = "Vnet Name"
  default = "az-spoke-vnet"
}


variable "account" {
  description = "The Azure account name, as known by the Aviatrix controller"
  type        = string
}


variable "instance_size" {
  description = "Azure Instance size for the Aviatrix gateways"
  type        = string
  default     = "Standard_B1ms"
}

variable "ha_gw" {
  description = "Boolean to determine if module will be deployed in HA or single mode"
  type        = bool
  default     = true
}

variable "active_mesh" {
  description = "Enables Aviatrix active mesh"
  type        = bool
  default     = true
}

variable "transit_gw" {
  description = "Transit gateway to attach spoke to"
  type        = string
}

variable "security_domain" {
  description = "Provide security domain name to which spoke needs to be deployed. Transit gateway mus tbe attached and have segmentation enabled."
  type        = string
  default     = ""
}

variable "single_az_ha" {
  description = "Set to true when Azure doesn't support Avaiablity Zones"
  type        = bool
  default     = false
}

variable "single_ip_snat" {
  description = "Specify whether to enable Source NAT feature in single_ip mode on the gateway or not. Please disable AWS NAT instance before enabling this feature. Currently only supports AWS(1) and AZURE(8). Valid values: true, false."
  type        = bool
  default     = false
}

variable "customized_spoke_vpc_routes" {
  description = "A list of comma separated CIDRs to be customized for the spoke VPC routes. When configured, it will replace all learned routes in VPC routing tables, including RFC1918 and non-RFC1918 CIDRs. It applies to this spoke gateway only​. Example: 10.0.0.0/116,10.2.0.0/16"
  type        = string
  default     = ""
}

variable "filtered_spoke_vpc_routes" {
  description = "A list of comma separated CIDRs to be filtered from the spoke VPC route table. When configured, filtering CIDR(s) or it’s subnet will be deleted from VPC routing tables as well as from spoke gateway’s routing table. It applies to this spoke gateway only. Example: 10.2.0.0/116,10.3.0.0/16"
  type        = string
  default     = ""
}

variable "included_advertised_spoke_routes" {
  description = "A list of comma separated CIDRs to be advertised to on-prem as Included CIDR List. When configured, it will replace all advertised routes from this VPC. Example: 10.4.0.0/116,10.5.0.0/16"
  type        = string
  default     = ""
}

variable "insane_mode" {
  description = "Set to true to enable Aviatrix high performance encryption."
  type        = bool
  default     = false
}
