#!/usr/bin/env bash
set -euo pipefail
command -v jq >/dev/null 2>&1 || { echo >&2 "Require 'jq' but it's not installed. Aborting."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo >&2 "Require 'kubectl' but it's not installed. Aborting."; exit 1; }

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PHROOT=$(realpath $DIR/../)
CONFIG_PATH=${CONFIG_PATH:-$($PHROOT/bin/phenv --path)}

info() {
  echo -e "\033[0;32m$1\033[0m"
}

warn() {
  echo -e "\033[0;93m$1\033[0m"
}

error() {
  echo -e "\033[0;91m$1\033[0m" >&2
}

init_config_path() {
  if [[ -d "$CONFIG_PATH" ]]; then
    warn "[Skip] Config folder already existed"
    return
  fi

  info "Create config folder"
  mkdir -p "${CONFIG_PATH}"
}

usage_PRIMEHUB_DOMAIN() {
  error "Please provide a domain name which can access to your cluster. (Ex. primehub.example-domain.com)"
  warn "For more detail information, please access https://docs.primehub.io/docs/next/getting_started/install_primehub to get help."
}

prepare_env_varible() {
  local name=$1
  local val=$(eval 'echo $'$name 2> /dev/null);
  if [[ ${val} ]]; then
    echo "$name = ${val}"
  else
    printf "Please enter ${name}: "; read ${name}; if [ "$(eval 'echo $'$name 2> /dev/null)" == "" ]; then echo "${name} not set"; return 1; fi
  fi
}

search_storage_class() {
  local target=$1
  if kubectl get sc | grep $target > /dev/null; then
    return 0
  fi
  return -1
}

init_env() {
  local envpath="$CONFIG_PATH/.env"

  if [[ -f $envpath ]]; then
    warn "[Skip] Config env already existed"
    return
  fi
  info "Create .env"

  prepare_env_varible PRIMEHUB_DOMAIN || (usage_PRIMEHUB_DOMAIN; exit 1)
  prepare_env_varible KC_PASSWORD || (info "Will auto generate KC_PASSWORD for you."; true)
  prepare_env_varible PH_PASSWORD || (info "Will auto generate PH_PASSWORD for you."; true)

  PRIMEHUB_NAMESPACE=${PRIMEHUB_NAMESPACE:-hub}
  PRIMEHUB_SCHEME=${PRIMEHUB_SCHEME:-http}

  PH_DOMAIN=${PH_DOMAIN:-${PRIMEHUB_DOMAIN}}
  PH_SCHEME=${PH_SCHEME:-${PRIMEHUB_SCHEME}}
  KC_DOMAIN=${KC_DOMAIN:-${PRIMEHUB_DOMAIN}}
  KC_SCHEME=${KC_SCHEME:-${PRIMEHUB_SCHEME}}

  KC_USER=${KC_USER:-keycloak}
  KC_REALM=${KC_REALM:-primehub}
  KC_SVC_URL="http://keycloak-http.${PRIMEHUB_NAMESPACE}/auth"

  KEYCLOAK_DEPLOY=${KEYCLOAK_DEPLOY:-true}
  METACONTROLLER_DEPLOY=${METACONTROLLER_DEPLOY:-true}

  PRIMEHUB_STORAGE_CLASS=${PRIMEHUB_STORAGE_CLASS:-$(kubectl get sc | grep '(default)' | cut -d' ' -f1 | head)}
  if search_storage_class "nfs-client"; then
    GROUP_VOLUME_STORAGE_CLASS="nfs-client"
  elif search_storage_class "microk8s-hostpath"; then
    GROUP_VOLUME_STORAGE_CLASS="microk8s-hostpath"
  fi

  # generate random
  ADMIN_UI_GRAPHQL_SECRET_KEY=${ADMIN_UI_GRAPHQL_SECRET_KEY:-$(openssl rand -hex 32)}
  HUB_AUTH_STATE_CRYPTO_KEY=${HUB_AUTH_STATE_CRYPTO_KEY:-$(openssl rand -hex 32)}
  HUB_PROXY_SECRET_TOKEN=${HUB_PROXY_SECRET_TOKEN:-$(openssl rand -hex 32)}
  PH_PASSWORD=${PH_PASSWORD:-$(openssl rand -hex 12)}
  KC_PASSWORD=${KC_PASSWORD:-$(openssl rand -hex 12)}

  local keys=(
    PRIMEHUB_NAMESPACE

    PRIMEHUB_DOMAIN
    PRIMEHUB_SCHEME
    PRIMEHUB_STORAGE_CLASS
    GROUP_VOLUME_STORAGE_CLASS
    PH_DOMAIN
    PH_SCHEME

    KC_DOMAIN
    KC_SCHEME
    KC_USER
    KC_PASSWORD
    KC_REALM
    KC_SVC_URL

    ADMIN_UI_GRAPHQL_SECRET_KEY

    HUB_AUTH_STATE_CRYPTO_KEY
    HUB_PROXY_SECRET_TOKEN

    PH_PASSWORD

    PRIMEHUB_AIRGAPPED

    KEYCLOAK_DEPLOY
    METACONTROLLER_DEPLOY
  )

  cp ${PHROOT}/etc/dotenv.example ${envpath}

  echo "" >> ${envpath}
  for key in "${keys[@]}"; do
    if [[ -z ${!key+x} ]]; then
      continue
    fi
    echo "$key=${!key}" >> ${envpath}
  done

  chmod 600 ${envpath}
}

init_helm_override() {
  if [[ -f "${CONFIG_PATH}/helm_override/primehub.yaml" ]]; then
    warn "[Skip] Config helm override already existed"
    return
  fi

  info "Create helm overrides"
  mkdir -p "$CONFIG_PATH/helm_override"
  cp $PHROOT/etc/helm_override/primehub.yaml "$CONFIG_PATH/helm_override/primehub.yaml"
  cp $PHROOT/etc/helm_override/primehub-grafana-dashboard-basic.yaml "$CONFIG_PATH/helm_override/primehub-grafana-dashboard-basic.yaml"
}

show_env() {
  local envpath="$CONFIG_PATH/.env"
  if [[ -f $envpath ]]; then
    info "Content of .env"
    cat $envpath | grep -v '^#.*' | grep -v '^$'
  fi
}

main() {
  init_config_path
  init_env
  init_helm_override
  show_env
  info "Complete"
}

main
