# Devbox

Terraform manages one Ubuntu development VM in Proxmox.

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
make devbox-check
make devbox
```

`make` lists the commands. `make devbox-preview` previews changes using
Ansible check mode; tasks requiring packages not yet installed may fail on a
fresh machine. Configure your Mac's `devbox` SSH alias before running the playbook.
