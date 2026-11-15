resource "proxmox_download_file" "ubuntu" {
  node_name    = var.proxmox_node
  datastore_id = "local"
  content_type = "import"
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name    = "ubuntu-24.04-server-cloudimg-amd64.qcow2"
  # Keep the installed image stable when Ubuntu publishes a newer daily image.
  overwrite = false
}

resource "proxmox_virtual_environment_vm" "devbox" {
  name        = var.vm_name
  description = "Devbox VM managed by Terraform"
  node_name   = var.proxmox_node
  on_boot     = true
  started     = true

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  serial_device {}

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    import_from  = proxmox_download_file.ubuntu.id
    interface    = "scsi0"
    size         = var.disk_size_gb
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  agent {
    enabled = var.guest_agent_enabled
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
