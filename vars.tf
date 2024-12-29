variable "host_os" {
  type        = string
  default     = ""
  description = "Host os name"
}

variable "subscriptionID" {
  type        = string
  default     = ""
  description = "Azure subscription ID"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure location"
}

variable "tenantID" {
  type        = string
  default     = ""
  description = "Azure tenant ID"
}

variable "target_environment" {
  type        = string
  default     = "LAB"
  description = "Target environment"
}

variable "environment_name_map" {
  type = map(string)
  default = {
    "LAB"  = "lab"
    "DEV"  = "dev"
    "PROD" = "prod"
  }
  description = "Map of environment names"
}

variable "environmet_vnet_cidr_map" {
  type = map(string)
  default = {
    "LAB"  = "10.123.0.0/16"
    "DEV"  = "10.124.0.0/16"
    "PROD" = "10.125.0.0/16"
  }
}

variable "environment_subnet_cidr_map" {
  type = map(string)
  default = {
    "LAB"  = "10.123.0.0/24"
    "DEV"  = "10.124.0.0/24"
    "PROD" = "10.125.0.0/24"
  }
}

variable "environment_subnet_name_map" {
  type = map(string)
  default = {
    "LAB"  = "lab"
    "DEV"  = "dev"
    "PROD" = "prod"
  }
}

variable "environment_vm_sku_map" {
  type = map(string)
  default = {
    "LAB"  = "Standard_A1_v2"
    "DEV"  = "Standard_A1_v2"
    "PROD" = "Standard_A1_v2"
  }
}