# k8s nodes
k8s_nodes = {
  k8s-master01 = {
    address        = "192.168.11.249/24"
    gateway_address = "192.168.11.1"
    dns_address     = "192.168.11.1"
    memory = 8096
    disk_size = 536870912000
  }
  k8s-worker01 = {
    address        = "192.168.11.248/24"
    gateway_address = "192.168.11.1"
    dns_address     = "192.168.11.1"
    memory = 8096
    disk_size = 536870912000
  }
  k8s-worker02 = {
    address        = "192.168.11.247/24"
    gateway_address = "192.168.11.1"
    dns_address     = "192.168.11.1"
    memory = 8096
    disk_size = 536870912000
  }
  k8s-worker03 = {
    address        = "192.168.11.246/24"
    gateway_address = "192.168.11.1"
    dns_address     = "192.168.11.1"
    memory = 8096
    disk_size = 536870912000
  }
}

