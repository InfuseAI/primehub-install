# PrimeHub Install

A repository helps you to install [PrimeHub](https://github.com/InfuseAI/primehub).

## Prerequisites

Basically, you need:

* A kubernetes cluster with v.17+ and required tools:
  * kubectl
  * helm, helm-diff and helmfile
  * make and jq
* A domain name or a public IP Address

Please check the details in the official document site:
https://docs.primehub.io/docs/getting_started/prerequisites

## Installation Steps

In this repository, we provide a Makefile that uses helmfile configurations to install PrimeHub.


1. Clone the repository `httsps://github.com/InfuseAI/primehub-install`

    ```bash
    git clone https://github.com/InfuseAI/primehub-install.git
    ```

2. Prepare the domain name or public IP address for PrimeHub

3. Install PrimeHub

    ```bash
    make install

    # Or install PrimeHub with specific version.
    #   PrimeHub Release Versions: https://github.com/InfuseAI/primehub/releases
    make install PRIMEHUB_VERSION=v3.4.1
    ```

    The installer will ask you to fill the domain name and the password of `keycloak` and `phadmin`. If input empty password, it will help to generate random password.

    ```bash
    $ make install
    Launch command './bin/config_init.sh' ...
    Create config folder
    Create .env
    Please enter PRIMEHUB_DOMAIN: example.primehub.com
    Please enter KC_PASSWORD: my-password-for-primehub
    Please enter PH_PASSWORD: my-password-for-primehub
    ...
    ```

## Start PrimeHub

  Visit the PrimeHub URL showing at the end of installing process.

  ```text
  [Status] PrimeHub

  PrimeHub:   http://example.primehub.com  ( phadmin / my-password-for-primehub )
  Id Server:  http://example.primehub.com/auth/admin/ ( keycloak / my-password-for-primehub )
  ```

## PrimeHub License Apply

  For PrimeHub Enterprise Edition users, the full features need to be enabled by PrimeHub License. Please reference the following link to apply.
  [Apply license](https://docs.primehub.io/docs/getting_started/install_primehub#apply-license-key-optional)

## Reconfiguration

The repository helps you basic installation, and it is possible to reconfigure it by yourself. 

First, find your configuration directory:

```bash
./bin/phenv --effective-path
/home/ubuntu/.primehub/config/local
```

All configurable files in the `effective path`:

```bash
$ tree -a /home/ubuntu/.primehub/config/local
/home/ubuntu/.primehub/config/local
|-- .env
`-- helm_override
    `-- primehub.yaml
```

Please check the [official document site](https://docs.primehub.io/docs/getting_started/configure-primehub-store) to reconfigure settings.
