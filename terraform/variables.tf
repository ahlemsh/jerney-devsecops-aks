variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Azure Resource Group name"
  type        = string
  default     = "rg-jerney-devsecops"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "jerney-devsecops"
}

variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-jerney"
}

variable "dns_prefix" {
  description = "AKS DNS prefix"
  type        = string
  default     = "jerney"
}

variable "node_count" {
  description = "Number of AKS worker nodes"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "AKS worker node VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vnet_cidr" {
  description = "VNet CIDR"
  type        = string
  default     = "10.20.0.0/16"
}

variable "aks_subnet_cidr" {
  description = "AKS subnet CIDR"
  type        = string
  default     = "10.20.1.0/24"
}

variable "service_cidr" {
  description = "Kubernetes service CIDR"
  type        = string
  default     = "10.21.0.0/16"
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP"
  type        = string
  default     = "10.21.0.10"
}

variable "pod_cidr" {
  description = "Kubernetes pod CIDR for kubenet"
  type        = string
  default     = "10.22.0.0/16"
}

variable "api_server_authorized_ip_ranges" {
  description = "Optional list of public IP ranges allowed to access AKS API server"
  type        = list(string)
  default     = []
}