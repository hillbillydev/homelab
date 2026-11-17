TERRAFORM ?= terraform
ANSIBLE_PLAYBOOK ?= ansible-playbook

.PHONY: help plan apply devbox devbox-check devbox-preview

help:
	@echo "make plan            Plan devbox infrastructure changes"
	@echo "make apply           Apply the saved plan"
	@echo "make devbox          Run the devbox Ansible playbook"
	@echo "make devbox-check    Check playbook syntax"
	@echo "make devbox-preview  Preview changes using Ansible check mode"

plan:
	@set -eu; if [ -f .env ]; then set -a; . ./.env; set +a; fi; \
	$(TERRAFORM) -chdir=terraform plan -input=false -out=homelab.tfplan

apply:
	@set -eu; if [ -f .env ]; then set -a; . ./.env; set +a; fi; \
	$(TERRAFORM) -chdir=terraform apply homelab.tfplan

devbox:
	cd ansible && $(ANSIBLE_PLAYBOOK) devbox.yml

devbox-check:
	cd ansible && $(ANSIBLE_PLAYBOOK) devbox.yml --syntax-check

devbox-preview:
	cd ansible && $(ANSIBLE_PLAYBOOK) devbox.yml --check --diff
