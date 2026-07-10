location            = "westeurope"
resource_group_name = "rg-jerney-devsecops"
project_name        = "jerney-devsecops"

aks_cluster_name = "aks-jerney"
dns_prefix       = "jerney"

node_count   = 1
node_vm_size = "Standard_D2s_v3"

vnet_cidr       = "10.20.0.0/16"
aks_subnet_cidr = "10.20.1.0/24"

service_cidr   = "10.21.0.0/16"
dns_service_ip = "10.21.0.10"
pod_cidr       = "10.22.0.0/16"

api_server_authorized_ip_ranges = []