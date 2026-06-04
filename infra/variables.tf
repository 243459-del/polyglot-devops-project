variable "azure_location" {
  type        = string
  default     = "Central India"
  description = "The target Azure data center region for the deployment."
}

variable "resource_group_name" {
  type        = string
  default     = "polyglot-devops-rg"
  description = "The name of the container group hosting all resources."
}

variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v3" # Swapping to standard compute tier to bypass over-allocated B-series blocks
  description = "The hardware profile size for the Ubuntu Virtual Machine."
}

variable "location" {
  description = "central India"
  type        = string
  default     = "central India"   # Change as needed
}