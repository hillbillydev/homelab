# Minimal devbox setup

Terraform creates Ubuntu, the hillbillydev user, and SSH access. This optional
playbook installs build-essential, bubblewrap (for Codex sandboxing), procps, file, ca-certificates, curl, git,
and APT repository support, plus
Tailscale, QEMU guest agent, Docker Engine with Compose/Buildx, and unattended
security updates. It enables
tailscaled at boot but does not enroll the machine.
Manage your dotfiles and development tools with chezmoi and mise separately.

## Connect and run

Both Ansible and interactive SSH use the `devbox` alias from your Mac's
`~/.ssh/config`. Configure its `HostName` with the current VM address,
`User hillbillydev`, and your SSH identity. No SSH client configuration is stored
in this project.

Find the rebuilt VM's DHCP address using MAC `BC:24:11:DC:B1:96`.
Connect once before running Ansible:

```sh
ssh devbox
```

Compare the offered host-key fingerprint with the VM's Proxmox console
(`ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`) before accepting it.
SSH and Ansible then use your normal `~/.ssh/known_hosts`; there is no separate
repository host-key file. Host key checking remains enabled.

Install Ansible on your Mac, then run from the project root:

```sh
brew install ansible
cd ansible
ansible-playbook devbox.yml --syntax-check
ansible-playbook devbox.yml
```

Repeat runs reconcile package installation and service state. Packages use
`state: present`; this does not perform a full OS upgrade.

## Join Tailscale

SSH into the devbox and run:

```sh
sudo tailscale up
```

Open the login link and authenticate. No Tailscale auth key is stored here.
Use `tailscale status` to check enrollment. Keep LAN access until you have
verified SSH through the machine's assigned Tailscale address or DNS name.
Normal SSH key authentication remains in use.

Package sources follow the [Tailscale Ubuntu instructions](https://pkgs.tailscale.com/stable/#ubuntu-noble).

## Guest agent and security updates

The playbook installs QEMU guest agent. Terraform's local and example settings
now enable its Proxmox channel. On an existing VM, install the package first,
apply Terraform, and fully stop/start the VM if the channel is absent. Rerun
Ansible after startup; the static agent service starts through its virtio device.
Proxmox can report guest addresses once the agent is connected.

Unattended upgrades run daily for Ubuntu security and applicable Ubuntu Pro ESM
security repositories. Third-party packages such as Tailscale remain manual.
Automatic reboots are disabled; check `/var/run/reboot-required` and reboot manually
when appropriate. These settings follow the
[Ubuntu automatic update documentation](https://ubuntu.com/server/docs/how-to/software/automatic-updates/).

Run only these additions with `--tags qemu,security_updates`.

## Docker

Installs Docker Engine, containerd, Compose, and Buildx from the
[official Docker APT repository](https://docs.docker.com/engine/install/ubuntu/),
and enables Docker and containerd at boot. Run just this setup with `--tags docker`.
The hillbillydev user is added to the docker group while preserving other memberships.
This grants root-level access through Docker; it is not rootless Docker.
Reconnect SSH after provisioning so the new group membership takes effect.

Check from that new session:

```sh
docker info
docker compose version
docker buildx version
# Optional: downloads and runs a test image.
docker run --rm hello-world
```

Docker packages are installed if absent; upgrades remain deliberate.

## GitHub SSH key

Ansible generates `~/.ssh/id_ed25519` for hillbillydev on the devbox, preserving
any existing key. The private key stays on the VM; only its public key is printed.
The generated key has no passphrase, so unattended reruns do not require input.
Add the public key to GitHub under Settings → SSH and GPG keys, then test from
the devbox with `ssh -T git@github.com`. GitHub registration is manual.

To generate or show just this key, run from the project root:

```sh
cd ansible
ansible-playbook devbox.yml --tags ssh_key
```

Back up a key you want to keep before rebuilding the VM; a fresh VM gets a new key.

## Login shell

Ansible installs Fish through APT and sets `/usr/bin/fish` as hillbillydev's
login shell. Reconnect SSH for it to take effect. Bash remains installed.
Run only this setup from `ansible/` with `ansible-playbook devbox.yml --tags shell`.
Personal Fish configuration belongs in chezmoi.

## Homebrew

Ansible runs the official noninteractive installer as the SSH user hillbillydev,
using `/home/linuxbrew/.linuxbrew`. Existing installations are preserved.
Ansible configures `/etc/fish/conf.d/homebrew.fish` for new Fish sessions.
Personal Fish configuration remains managed separately by chezmoi.
Run only this setup from `ansible/` with `ansible-playbook devbox.yml --tags homebrew`.
The full playbook also installs chezmoi through Homebrew as hillbillydev.
It does not install mise, initialize dotfiles, or apply Brewfile packages.
Once Homebrew is installed, run just chezmoi setup with `--tags chezmoi`.

## Swarm manager

`swarm.yml` configures `swarm-01` at its reserved LAN address `192.168.0.29`.
It sets the hostname, installs Docker Engine/Compose/Buildx and QEMU guest agent,
enables security updates without automatic reboots, and initializes a Swarm
manager advertising its reserved LAN IP. Repeat runs preserve the cluster;
unexpected existing Swarm membership fails rather than replacing it. Join tokens
are not printed. The hillbillydev user is kept out of the Docker group;
use `sudo docker` on Swarm nodes. Ansible runs Docker tasks with privilege
escalation. Devbox keeps its separate Docker group access.

From `ansible/`, run `ansible-playbook swarm.yml --syntax-check`, then
`ansible-playbook swarm.yml`.
Guest-agent startup requires the channel enabled in Proxmox and potentially a
full stop/start; the package is installed even when the channel is absent.
This playbook installs no development tools or application stacks.
