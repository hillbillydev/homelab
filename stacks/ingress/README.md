# Ingress

Public requests follow Cloudflare → cloudflared → Traefik → application services.
Terraform owns DNS and tunnel hostname routing to http://traefik:80.
The stack runs cloudflared, Traefik, and a Docker API socket proxy.
All images are pinned by digest. No host ports or Traefik dashboard are published.
HTTPS terminates at Cloudflare; cloudflared uses an encrypted outbound tunnel,
then HTTP to Traefik inside the Swarm overlay network.

Traefik discovers Swarm service labels. Only explicitly enabled services are
routed. Its Docker API access goes through a private socket proxy allowing
read-only discovery endpoints; secrets and write requests are blocked.
Only the proxy mounts the Docker socket. The private API network connects just
Traefik and the proxy. The web network is shared with routed app stacks.

## Deploy

Run from the project root in zsh/bash. These are the same deployment operations
used for the initial setup; there are no additional manual host modifications.
Ansible prepares Docker and Swarm; the commands below deploy the application stack.

```sh
set -a
source .env
set +a
python3 scripts/provision-tunnel-secret.py
ssh hillbillydev@192.168.0.29 'sudo -n docker network inspect web >/dev/null 2>&1 || sudo -n docker network create --driver overlay --attachable web'
ssh hillbillydev@192.168.0.29 'sudo -n docker stack deploy --compose-file - ingress' < stacks/ingress/stack.yml
ssh hillbillydev@192.168.0.29 'sudo -n docker stack services ingress'
```

The secret script fetches the connector token and sends it over SSH directly
into a Swarm secret. It does not print the token or write a plaintext token file.
Existing secrets are preserved; rotation is a separate operation.
cloudflared reads the token from its mounted secret as a non-root user.

Stack deployment returns before rollout finishes. Check service replicas and
health before updating Cloudflare routing. A one-replica service can briefly
be unavailable during updates. The web overlay is attachable for administrative
checks and future routed services; it publishes no ports on the host.

See ../hello/README.md for the test application's deployment.
