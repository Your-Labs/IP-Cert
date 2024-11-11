#!/usr/bin/env bash


nginx_bin=$(which nginx)
"$nginx_bin" -s stop > /dev/null 2>&1 &
sleep 1