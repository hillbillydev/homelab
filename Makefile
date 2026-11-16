TERRAFORM ?= terraform
ANSIBLE_PLAYBOOK ?= ansible-playbook
SWARM_SSH ?= hillbillydev@192.168.0.29

.PHONY: help plan apply setup deploy status

help:
	@echo 'make plan                 Plan infrastructure changes'
	@echo 'make apply                Apply the saved plan'
	@echo 'make setup HOST=swarm     Configure swarm (or HOST=devbox)'
	@echo 'make deploy STACK=hello   Deploy a stack (or STACK=ingress)'
	@echo 'make status               Show Swarm services'

plan:
	@set -eu; set -a; . ./.env; set +a; \
	$(TERRAFORM) -chdir=terraform plan -input=false -out=homelab.tfplan

apply:
	@set -eu; set -a; . ./.env; set +a; \
	$(TERRAFORM) -chdir=terraform apply homelab.tfplan

setup:
	@case '$(HOST)' in devbox|swarm) ;; *) echo 'Use HOST=devbox or HOST=swarm'; exit 1;; esac
	cd ansible && $(ANSIBLE_PLAYBOOK) $(HOST).yml

deploy:
	@case '$(STACK)' in ''|*[!a-zA-Z0-9_-]*) echo 'Set STACK to a directory name under stacks/'; exit 1;; esac
	@test -f 'stacks/$(STACK)/stack.yml' || { echo 'Stack file not found'; exit 1; }
	ssh $(SWARM_SSH) 'sudo -n docker stack deploy --detach=false --compose-file - $(STACK)' < stacks/$(STACK)/stack.yml

status:
	ssh $(SWARM_SSH) 'sudo -n docker service ls'
