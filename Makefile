ANSIBLE_PLAYBOOK ?= ansible-playbook

.PHONY: help devbox devbox-check devbox-preview

help:
	@echo "make devbox          Run the devbox Ansible playbook"
	@echo "make devbox-check    Check playbook syntax"
	@echo "make devbox-preview  Preview changes using Ansible check mode"

devbox:
	cd ansible && $(ANSIBLE_PLAYBOOK) devbox.yml

devbox-check:
	cd ansible && $(ANSIBLE_PLAYBOOK) devbox.yml --syntax-check

devbox-preview:
	cd ansible && $(ANSIBLE_PLAYBOOK) devbox.yml --check --diff
