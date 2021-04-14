# Provision

The `cdk` module provides a docker image to launch aws-cdk that helps PrimeHub partners to create a multi-node sample.

## Usage

In order to make the cdk image working, you have to provide:

* the `$HOME/.aws` configuration
* arguments to create your own cluster
  * NAME is used in the node name
  * USERNAME is used in the resource tag
  * KEY\_NAME is the name of your key used to `ssh` login


```
docker run --rm -it -v $HOME/.aws:/root/.aws:ro \
  -e NAME=demo -e USERNAME=demo -e KEY_NAME=demo_key \
  infuseai/cdk:v0.1 cdk deploy
```
