output "vm_id" {
  description = "Allocated Proxmox VM ID."
  value       = proxmox_virtual_environment_vm.devbox.vm_id
}

output "vm_name" {
  value = proxmox_virtual_environment_vm.devbox.name
}

output "proxmox_node" {
  value = proxmox_virtual_environment_vm.devbox.node_name
}

output "ipv4_addresses" {
  description = "Guest IPv4 addresses; populated only when the guest agent is enabled and running."
  value       = proxmox_virtual_environment_vm.devbox.ipv4_addresses
}

output "postgres_container_id" {
  description = "Allocated Proxmox container ID for the Postgres LXC."
  value       = proxmox_virtual_environment_container.postgres.vm_id
}
