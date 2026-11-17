# Proxmox guests

## Devbox VM

Creates an Ubuntu 24.04 LTS VM named `devbox` directly from the official cloud
image, with no template or manual OS installation needed. Defaults: 8 GiB
RAM, 4 CPU cores, a 64 GiB boot disk, DHCP networking, and SSH key access.
The VM starts automatically, including after the Proxmox host reboots.

## Postgres LXC

Creates a separate unprivileged Ubuntu 24.04 container named `postgres` that
starts at boot. It defaults to 2 vCPUs, 2 GiB of RAM, and a 32 GiB root disk
on `datastore_id`. It uses DHCP on `network_bridge` and authorizes the existing
`ssh_public_keys` for the container's root account.

After applying, find the container in Proxmox using
`terraform output postgres_container_id`. Reserve its DHCP address before
connecting the Swarm VM. Terraform provisions the guest. To install
PostgreSQL, open the container console or connect as root with your SSH key
and run:

```sh
apt-get update
apt-get install -y postgresql
pg_isready
```

Keep PostgreSQL on localhost during bootstrap. When the Swarm VM is ready,
configure PostgreSQL to listen on the container's private address, restrict
TCP 5432 to the Swarm VM, and create a database and role for each backend.
Database files live on the container root disk. Keep database backups off
the Proxmox host and test restoring them.

## Prerequisites

- Terraform >= 1.5, Proxmox VE >= 8.4, and access to its HTTPS API.
- A Proxmox API token with permissions to download images, allocate/configure
  VMs, allocate storage, use the network bridge, and start VMs. With token privilege
  separation enabled, both its user and token need the appropriate permissions.
- `local` storage with the Import content type enabled (already verified on pve).
- Internet access from Proxmox to download the Ubuntu cloud image.
- A storage pool that supports VM disks and an existing bridge with DHCP.
- For the LXC, enable CT template content on `local` and container content on
  `datastore_id`. The API token also needs permission to download CT templates
  and allocate, configure, and start containers.

## Configure and create

If you use mise, run `mise install` from the repository root on the machine
where you run Terraform. The root `mise.toml` pins the Terraform CLI version.
If mise is inactive in your shell, prefix Terraform commands with
`mise exec --`.

Edit `terraform.tfvars` for the endpoint, Proxmox host name,
storage/bridge if needed, and SSH public key. On a fresh checkout, copy
`terraform.tfvars.example` to `terraform.tfvars` first. `proxmox_node` is the
existing physical Proxmox host; `devbox` is the new guest VM.
The local tfvars file is ignored by Git.

To save the token for this checkout, add it to the Git-ignored
`mise.local.toml` at the repository root. Set the file permissions to
`chmod 600 mise.local.toml`.

```toml
[env]
TF_VAR_proxmox_api_token = "user@realm!token-name=secret"
```

Run Terraform through `mise exec -- terraform` to load it when mise is
inactive in your shell. For a one-off session, you can instead enter the
token without putting it in shell history (zsh):

```sh
read -rs 'TF_VAR_proxmox_api_token?Proxmox API token (user@realm!token=secret): '
export TF_VAR_proxmox_api_token
```

Run from this directory:

```sh
terraform init
terraform plan -out=homelab.tfplan
terraform apply homelab.tfplan
```

From the repository root, `mise exec -- make plan` and
`mise exec -- make apply` run the same plan and apply steps. These targets
also support the Git-ignored root `.env` file for credentials when present.

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
