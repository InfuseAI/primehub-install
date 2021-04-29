.PHONY: help

PRIMEHUB_VERSION=
PRIMEHUB_PATH=
PRIMEHUB_NAMESPACE ?= hub
PRIMEHUB_MODE ?= ee

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
	@echo "Launch command './bin/misc/init_env' ..."
	@bin/misc/init_env

diff:
	@echo "Launch command '$(pwd)/bin/phenv helmfile diff --context 2 --skip-deps --args '--disable-validation' ..."
	@bin/phenv helmfile diff --context 2 --skip-deps --args '--disable-validation'

sync:
	@echo "Launch command './bin/phenv helmfile sync' ..."
	@bin/phenv helmfile sync

status:
	@bin/misc/status

install: init sync status

install-grafana-dashboard:
	@bin/misc/preflight-grafana-dashboard
	@echo "Launch command './bin/phenv helmfile -f values/primehub-grafana-dashboard-basic.yaml sync' ..."
	@bin/phenv helmfile -f values/primehub-grafana-dashboard-basic.yaml sync

diff-grafana-dashboard:
	@bin/misc/preflight-grafana-dashboard
	@echo "Launch command '$(pwd)/bin/phenv helmfile -f values/primehub-grafana-dashboard-basic.yaml diff --context 2 --skip-deps --args '--disable-validation' ..."
	@bin/phenv helmfile -f values/primehub-grafana-dashboard-basic.yaml diff --context 2 --skip-deps --args '--disable-validation'

destroy:
	@echo "Launch command './bin/phenv helmfile destroy' ..."
	@bin/phenv helmfile destroy
	@bin/misc/cleanup
