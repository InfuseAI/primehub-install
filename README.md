# PrimeHub Install

A repo help to install [PrimeHub](https://github.com/InfuseAI/primehub).

## Prerequisites

Please follow the steps of the following link to setup Kubernetes environment.
https://docs.primehub.io/docs/getting_started/prerequisites

## Installation Steps

1. Clone the repo `https://github.com/InfuseAI/primehub-install`

    ```bash
    git clone https://github.com/InfuseAI/primehub-install
    ```

2. Prepare the domain name or public IP address for PrimeHub

3. Install PrimeHub

    ```bash
    make install
    ```

    The installer will ask you to fill the domain name and the password of `keycloak` and `phadmin`. If input empty password, it will help to generate random password.
