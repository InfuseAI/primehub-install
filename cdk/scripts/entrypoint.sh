#!/usr/bin/env bash

set -e

if [ -z ${NAME+x} ]; then
    echo "env NAME is required"
    exit 1
fi

if [ -z ${USERNAME+x} ]; then
    echo "env USERNAME is required"
    exit 1
fi

if [ -z ${KEY_NAME+x} ]; then
    echo "env KEY_NAME is required"
    exit 1
fi

exec "$@"
