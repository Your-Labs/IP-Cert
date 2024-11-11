#!/usr/bin/env bash

RENEW_ARG=""

if [ -f "/data/current.yaml" ]; then
    RENEW_ARG="-renew"
fi

CMD="zerossl-ip-cert ${RENEW_ARG} -config /config.yaml"
echo "Run CMD: ${CMD}"

$CMD