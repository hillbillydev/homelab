# Devbox

Terraform manages separate Ubuntu VMs for development (`devbox`) and
application services (`swarm-01`) in Proxmox.

- [Terraform](terraform/README.md) creates a fresh Ubuntu VM with SSH access.
- [Ansible](ansible/README.md) is optional and is not run during provisioning.

Configure the `devbox` alias in your Mac’s `~/.ssh/config`, then connect:

```sh
ssh devbox
```

Terraform state stays in the local checkout. Use a single checkout to manage the VM.

Install Ansible on your Mac with Homebrew, then run from this directory:

```sh
brew install ansible
cd ansible
ansible-playbook devbox.yml --syntax-check
ansible-playbook devbox.yml
```

Use `ansible-playbook swarm.yml` from `ansible/` to configure swarm-01.
Preview a playbook with `--check --diff`; tasks requiring packages not yet installed
may fail on a fresh machine. Configure your Mac's devbox SSH alias before connecting.

VMs, Cloudflare tunnel, and public DNS are managed together in [terraform/](terraform/README.md).

## Local Terraform credentials

Fill in the single-quoted values in the Git-ignored `.env` at the project root.
It is plaintext with owner-only permissions (`600`). Load it once in your
Mac terminal session (zsh/bash), then run Terraform directly:

```sh
set -a
source .env
set +a
terraform -chdir=terraform init
terraform -chdir=terraform plan -out=homelab.tfplan
terraform -chdir=terraform apply homelab.tfplan
```

Review the saved plan before applying. Apply uses `terraform/homelab.tfplan`;
regenerate the plan after changing configuration. Terraform must be on PATH.
Non-secret settings live in `terraform/terraform.tfvars`. State and saved plans
can contain secrets and stay excluded from Git.

## Common commands

The Makefile is a thin wrapper around the commands documented above:

```sh
make plan
make apply
make setup HOST=swarm
make deploy STACK=hello
make status
```

Run `make` for help. Setup requires `HOST=devbox` or `HOST=swarm`; deployment
requires a stack directory such as `STACK=hello` or `STACK=ingress`.
Plan and apply load `.env` locally. Apply uses the saved plan without replanning
and does not prompt again, so review `make plan` before running it.
Initialize Terraform once with `terraform -chdir=terraform init` first.

Deployment sends the stack file over SSH and waits for rollout. It does not run
Terraform, Ansible, or create prerequisite networks, configs, or secrets.
For a new installation, follow the ingress and hello stack READMEs first.
Override `SWARM_SSH` when deploying from a machine with a different connection.
The repo is not required on the Swarm node.
