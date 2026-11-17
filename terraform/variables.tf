variable "proxmox_endpoint" {
  description = "Proxmox API URL, including https:// and port 8006."
  type        = string
}

variable "proxmox_api_token" {
  description = "API token in user@realm!token-name=secret format; set with TF_VAR_proxmox_api_token."
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Allow the devbox Proxmox host's self-signed TLS certificate."
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Existing Proxmox host on which to create the VM."
  type        = string
}

variable "vm_name" {
  description = "Name of the guest VM."
  type        = string
  default     = "devbox"
}

variable "cpu_cores" {
  description = "Number of virtual CPU cores."
  type        = number
  default     = 4
}

variable "memory_mb" {
  description = "Dedicated guest RAM in MiB (8192 = 8 GiB)."
  type        = number
  default     = 8192
}

variable "disk_size_gb" {
  description = "Boot disk size in GiB."
  type        = number
  default     = 64
}

variable "datastore_id" {
  description = "Storage for the VM and cloud-init disk."
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Existing Proxmox bridge connected to a network with DHCP."
  type        = string
  default     = "vmbr0"
}

variable "ssh_username" {
  description = "Linux account created by cloud-init."
  type        = string
  default     = "hillbillydev"
}

variable "ssh_public_keys" {
  description = "SSH public keys allowed to log in to the guest."
  type        = list(string)

  validation {
    condition     = length(var.ssh_public_keys) > 0 && alltrue([for key in var.ssh_public_keys : can(regex("^ssh-|^ecdsa-", trimspace(key)))])
    error_message = "Supply at least one SSH public key (not a private key)."
  }
}

variable "guest_agent_enabled" {
  description = "Enable the Proxmox guest-agent channel; Ansible installs the agent inside Ubuntu."
  type        = bool
  default     = false
}
