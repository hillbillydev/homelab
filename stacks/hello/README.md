# Nginx hello application

This separate Swarm stack serves https://hello.schedoodle.com through the shared
ingress stack. Nginx is pinned by image digest, with no published host ports.
Its deploy.labels define the Traefik hostname route and internal target port.
The page content is stored in index.html and mounted through a Docker config.

After deploying ingress and its shared web network, run from the project root:

```sh
ssh hillbillydev@192.168.0.29 'sudo -n docker config inspect hello_index_v1 >/dev/null 2>&1 || sudo -n docker config create hello_index_v1 -' < stacks/hello/index.html
ssh hillbillydev@192.168.0.29 'sudo -n docker stack deploy --compose-file - hello' < stacks/hello/stack.yml
ssh hillbillydev@192.168.0.29 'sudo -n docker stack services hello'
curl --fail https://hello.schedoodle.com
```

Docker configs are immutable. When changing index.html, increment the config
name in stack.yml and the create command (for example hello_index_v2), create
that config, and redeploy. The existing name is preserved on repeat runs.
Remove an old config only after no service references it.

For another application, attach it to web, set traefik.enable=true and its
service labels, then add the explicit hostname in Terraform public_hostnames.
Apps needing databases should use a separate private network for those services.
