resource "proxmox_download_file" "postgres_template" {
  node_name    = var.proxmox_node
  datastore_id = "local"
  content_type = "vztmpl"
  url          = "https://download.proxmox.com/images/system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  overwrite    = false
}

resource "proxmox_virtual_environment_container" "postgres" {
  description   = "PostgreSQL LXC managed by Terraform"
  node_name     = var.proxmox_node
  unprivileged  = true
  start_on_boot = true
  started       = true

  cpu {
    cores = var.postgres_cpu_cores
  }

  memory {
    dedicated = var.postgres_memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.postgres_disk_size_gb
  }

  operating_system {
    template_file_id = proxmox_download_file.postgres_template.id
    type             = "ubuntu"
  }

  initialization {
    hostname = "postgres"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = var.ssh_public_keys
    }
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }
}
