terraform {
  required_version = "~> 1.1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

variable "k8s_nodes" {
  description = "k8s node infomation"
  type = map(object({
    address         = string
    gateway_address = string
    dns_address     = string
    memory = number
    disk_size = number
  }))
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu-qcow2" {
  name   = "ubuntu-qcow2"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")

  for_each = var.k8s_nodes
  vars = {
    hostname = "${each.key}"
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")

  for_each = var.k8s_nodes
  vars = {
    address        = "${each.value.address}"
    gateway_address = "${each.value.gateway_address}"
    dns_address    = "${each.value.dns_address}"
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = var.k8s_nodes 
  name           = "cloud_init_${each.key}.iso"
  user_data      = data.template_file.user_data["${each.key}"].rendered
  network_config = data.template_file.network_config["${each.key}"].rendered
}

resource "libvirt_volume" "ubuntu-node" {
  for_each       = var.k8s_nodes
  name           = "ubuntu-base-${each.key}"
  base_volume_id = libvirt_volume.ubuntu-qcow2.id
  size           = 536870912000
}

# resource "libvirt_network" "ubuntu-node-network01" {
#    name = "ubuntu-node-network01"
#    mode = "bridge"
#    bridge = "br0"
#}

resource "libvirt_domain" "k8s-node" {
  for_each = var.k8s_nodes

  name   = "${each.key}"
  memory = "${each.value.memory}"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.commoninit["${each.key}"].id

  autostart = true

  network_interface {
    bridge = "br0"
  }

  boot_device {
    dev = ["hd", "network"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.ubuntu-node["${each.key}"].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true

  }
}

#resource "libvirt_volume" "ubuntu-node-worker02" {
#    name = "ubuntu-base-worker02"
#    base_volume_id = libvirt_volume.ubuntu-qcow2.id
#    size = 536870912000
#}
#
#resource "libvirt_network" "ubuntu-node-network02" {
#    name = "ubuntu-node-network02"
#    mode = "bridge"
#    bridge = "br0"
#    addresses = ["192.168.11.248/24"]
#}
#
#resource "libvirt_domain" "k8s-node-worker02" {
#    name = "worker02"
#    memory = "8096"
#    vcpu = 4
#
#    cloudinit = libvirt_cloudinit_disk.commoninit.id
#
#    network_interface {
#        bridge = "br0"
#    }
#
#    console {
#        type = "pty"
#        target_port = "0"
#        target_type = "serial"
#    }
#
#    console {
#        type = "pty"
#        target_type = "virtio"
#        target_port = "1"
#    }
#
#    disk {
#        volume_id = libvirt_volume.ubuntu-node-worker02.id
#    }
#
#    graphics {
#        type = "spice"
#        listen_type = "address"
#        autoport = true
#
#    }
#}
#
