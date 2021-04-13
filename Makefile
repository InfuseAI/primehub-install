.PHONY: help

help:
	@echo "PrimeHub Install"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "targets:"
	@echo " - init       <- Generate environemnt for PrimeHub"
	@echo " - diff       <- Diff PrimeHub"
	@echo " - sync       <- Apply PrimeHub"
	@echo " - install    <- Install PrimeHub"
	@echo " - destroy    <- Destroy PrimeHub"

init:
	@echo "Launch command './bin/config_init.sh' ..."
	@bin/config_init.sh

diff:
	@echo "Launch command './bin/phenv helmfile diff' ..."
	@bin/phenv helmfile diff

sync:
	@echo "Launch command './bin/phenv helmfile sync' ..."
	@bin/phenv helmfile sync

install: init sync

destroy:
	@echo "Launch command './bin/phenv helmfile destroy' ..."
	@bin/phenv helmfile destroy
