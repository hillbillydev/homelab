resource "proxmox_virtual_environment_vm" "swarm" {
  name        = "swarm-01"
  description = "Docker Swarm VM managed by Terraform"
  node_name   = var.proxmox_node
  on_boot     = true
  started     = true

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  serial_device {}

  cpu {
    cores = var.swarm_cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.swarm_memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    import_from  = proxmox_download_file.ubuntu.id
    interface    = "scsi0"
    size         = var.swarm_disk_size_gb
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  agent {
    enabled = false
  }

  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = var.ssh_username
      keys     = var.ssh_public_keys
    }
  }
}
