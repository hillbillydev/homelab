# Devbox infrastructure

Terraform manages one Ubuntu 24.04 development VM in Proxmox, with 4 CPU
cores, 8 GiB RAM, a 64 GiB disk, DHCP, and SSH access as hillbillydev.
It starts automatically at host boot. Ansible manages guest packages and services.

## Setup

Install Terraform >= 1.5. On a fresh checkout, copy terraform.tfvars.example
to terraform.tfvars and fill in the Proxmox settings and SSH public key.
Preserve existing local settings. The Proxmox API token needs permission to
manage images, VMs, storage, and networking on the configured node.

Store the token in the Git-ignored .env at the project root:

```dotenv
TF_VAR_proxmox_api_token='...'
```

Keep .env owner-readable only (`chmod 600 .env`). From the project root:

```sh
terraform -chdir=terraform init
make plan
make apply
make devbox
```

Review the plan before applying. Apply uses terraform/homelab.tfplan;
regenerate it after changing configuration. Terraform does not run Ansible.
The Makefile loads .env for plan and apply. To run Terraform directly in bash/zsh,
load credentials with `set -a; source .env; set +a` first.

## Access and state

Connect using your Mac's configured `ssh devbox` alias or the guest's DHCP address.
Guest IP outputs require a running QEMU guest agent and its Proxmox channel;
a full stop/start may be required after enabling the channel.
The provider accepts self-signed certificates by default; set
proxmox_insecure = false when the host has a trusted certificate.

Disks can grow but cannot shrink in place. Use one checkout to manage local
state and back it up before rebuilding that machine. Credentials, local tfvars,
state, and saved plans stay excluded from Git. Commit the provider lockfile.
