# Devbox VM

## Devbox VM

Creates an Ubuntu 24.04 LTS VM named `devbox` directly from the official cloud
image, with no template or manual OS installation needed. Defaults: 8 GiB
RAM, 4 CPU cores, a 64 GiB boot disk, DHCP networking, and SSH key access.
The VM starts automatically, including after the Proxmox host reboots.

## Prerequisites

- Terraform >= 1.5, Proxmox VE >= 8.4, and access to its HTTPS API.
- A Proxmox API token with permissions to download images, allocate/configure
  VMs, allocate storage, use the network bridge, and start VMs. With token privilege
  separation enabled, both its user and token need the appropriate permissions.
- `local` storage with the Import content type enabled (already verified on pve).
- Internet access from Proxmox to download the Ubuntu cloud image.
- A storage pool that supports VM disks and an existing bridge with DHCP.

## Configure and create

Edit `terraform.tfvars` for the endpoint, Proxmox host name,
storage/bridge if needed, and SSH public key. On a fresh checkout, copy
`terraform.tfvars.example` to `terraform.tfvars` first. `proxmox_node` is the
existing physical Proxmox host; `devbox` is the new guest VM.
The local tfvars file is ignored by Git.

Supply the token without putting it in shell history (zsh):

```sh
read -rs 'TF_VAR_proxmox_api_token?Proxmox API token (user@realm!token=secret): '
export TF_VAR_proxmox_api_token
```

Run from this directory:

```sh
terraform init
terraform plan -out=devbox.tfplan
terraform apply devbox.tfplan
```

The existing provider configuration allows self-signed certificates. Set
`proxmox_insecure = false` when the host has a trusted TLS certificate.

Find the VM's address in your DHCP leases or Proxmox console, then connect with
`ssh hillbillydev@<address>`. To expose addresses through Terraform outputs, install
and start `qemu-guest-agent` inside the VM, then set
`guest_agent_enabled = true` and plan/apply again. The agent is optional and is
disabled by default. This configuration does not install the agent.

## Current access

VM 100 runs Ubuntu with hostname `devbox` and login user `hillbillydev`.
Ansible configures its base packages and services.
Its network MAC is `BC:24:11:DC:B1:96`; find its DHCP address in your router
and configure the `devbox` alias in your Mac’s `~/.ssh/config` with that
address and `User hillbillydev` before connecting:

```sh
ssh devbox
```

The current VM address still needs to be confirmed.
Apply your chezmoi dotfiles after connecting. Terraform does not run chezmoi
or Ansible automatically.

Adjust the CPU, RAM, and disk values later and review another plan before applying.
Disk capacity can grow but cannot shrink in place. Back up Terraform state; local
state and saved plans are ignored by Git. Commit the generated dependency lockfile
after initialization.

Provider reference: https://registry.terraform.io/providers/bpg/proxmox/0.110.0/docs/resources/virtual_environment_vm
