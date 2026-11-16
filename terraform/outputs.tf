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

output "swarm" {
  description = "Swarm VM details; match its MAC address to a DHCP lease."
  value = {
    vm_id    = proxmox_virtual_environment_vm.swarm.vm_id
    name     = proxmox_virtual_environment_vm.swarm.name
    username = var.ssh_username
    mac      = proxmox_virtual_environment_vm.swarm.network_device[0].mac_address
  }
}

output "tunnel_id" {
  description = "Tunnel ID for the Swarm cloudflared connector."
  value       = cloudflare_zero_trust_tunnel_cloudflared.homelab.id
}

output "public_hostnames" {
  value = sort(tolist(var.public_hostnames))
}
