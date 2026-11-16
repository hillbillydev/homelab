# Homelab infrastructure

One Terraform configuration and local state manages the Proxmox VMs and Cloudflare.
All `.tf` files here are loaded together; filenames are for readability.

- `devbox.tf`: shared Ubuntu image and development VM.
- `swarm.tf`: swarm-01, with 4 CPU cores, 8 GiB RAM, and a 128 GiB disk.
- `tunnel.tf`: shared Cloudflare tunnel, app DNS records, and ingress rules.
- `providers.tf`, `variables.tf`, `outputs.tf`: shared configuration.

## Setup and commands

Install Terraform >= 1.5. Copy terraform.tfvars.example to terraform.tfvars on
a fresh checkout and fill in the non-secret Proxmox settings, SSH public key,
Cloudflare account ID, and schedoodle.com zone ID. Preserve existing local settings.
Use one checkout to manage this state; back it up before rebuilding that machine.

Tokens belong in the Git-ignored `.env` at the project root:

```dotenv
TF_VAR_proxmox_api_token='...'
CLOUDFLARE_API_TOKEN='...'
```

The Cloudflare token needs tunnel write access for the account and DNS write
access for the zone. Zone read is needed for discovering zone information.
The Proxmox token needs VM/storage/network permissions for the configured node.
The provider currently accepts the Proxmox host's self-signed certificate.

From the project root in a zsh/bash terminal:

```sh
set -a
source .env
set +a
terraform -chdir=terraform init
terraform -chdir=terraform plan -out=homelab.tfplan
terraform -chdir=terraform apply homelab.tfplan
```

Review the plan before applying: it covers both providers. The saved plan is
terraform/homelab.tfplan; regenerate it after changing configuration. Credentials,
local tfvars, state, and plans stay excluded from Git. Commit the provider lockfile.
Terraform does not run Ansible or deploy Swarm stacks.

## VMs

Ubuntu 24.04 guests use DHCP, SSH public-key login as hillbillydev, and start at
host boot. Devbox defaults to 4 CPUs, 8 GiB RAM, and 64 GiB disk. Swarm sizing
can be overridden with swarm_cpu_cores, swarm_memory_mb, and swarm_disk_size_gb.
Disks can grow but cannot shrink in place.

VM 100 is devbox; VM 101 is swarm-01. Swarm's MAC is BC:24:11:04:F3:77,
reserved at 192.168.0.29. The devbox uses your Mac's SSH alias and Tailscale.
Ansible manages guest packages and services. Guest IP outputs require a running
QEMU agent and its channel enabled in Proxmox; a full stop/start may be required
after enabling the channel. Swarm's channel is currently disabled in swarm.tf.

## Cloudflare and ingress

schedoodle.com is active in Cloudflare. Terraform manages one tunnel named homelab
and explicit app DNS records. It does not manage nameservers, email records,
wildcards, or the apex record. Import any existing app record before managing
it here rather than creating a duplicate.

hello.schedoodle.com routes through http://traefik:80, followed by a catch-all
404. This is public routing without an Access login policy. Add authentication
before exposing private services.

The connector and Traefik run from stacks/ingress/ on Swarm, and the Nginx test
app runs from stacks/hello/. Follow their READMEs for direct deployment commands.
The connector token is provisioned with scripts/provision-tunnel-secret.py using
the Cloudflare API token from .env. It is piped directly into a Docker secret,
without printing it or storing it in Terraform state. No router port forwarding
is required.
