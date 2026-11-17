# Devbox

Terraform manages an Ubuntu development VM and a separate Ubuntu LXC for PostgreSQL in Proxmox.

- [Terraform](terraform/README.md) provisions both guests and documents PostgreSQL installation.
- [Ansible](ansible/README.md) is optional and is not run during provisioning.

Configure the `devbox` alias in your Mac’s `~/.ssh/config`, then connect:

```sh
ssh devbox
```

Terraform state stays in the local checkout. Use a single checkout to manage the guests.

Install the pinned Terraform and Ansible tools with mise, then run from this
directory:

```sh
mise install
mise exec -- make devbox-check
mise exec -- make devbox
```

`make` lists the commands. `make devbox-preview` previews changes using
Ansible check mode; tasks requiring packages not yet installed may fail on a
fresh machine. Configure your Mac's `devbox` SSH alias before running the playbook.
