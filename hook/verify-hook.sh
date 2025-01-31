#!/usr/bin/env bash

echo "nginx verify hook running"

echo "ZEROSSL_HTTP_FV_HOST: $ZEROSSL_HTTP_FV_HOST"
echo "ZEROSSL_HTTP_FV_PATH: $ZEROSSL_HTTP_FV_PATH"
echo "ZEROSSL_HTTP_FV_PORT: $ZEROSSL_HTTP_FV_PORT"
echo "ZEROSSL_HTTP_FV_CONTENT: $ZEROSSL_HTTP_FV_CONTENT"

nginx_bin=$(which nginx)
echo "nginx_bin: $nginx_bin"

if [ "$ZEROSSL_HTTP_FV_PORT" = "" ] || [ "$ZEROSSL_HTTP_FV_PORT" = "0" ]; then
    ZEROSSL_HTTP_FV_PORT=80
fi

file_content=$(echo "$ZEROSSL_HTTP_FV_CONTENT" | tr -d '\r' | awk '{printf "%s\\n", $0}')
echo "file_content: $file_content"
cat <<EOF >/etc/nginx/conf.d/verify.conf
server {
    listen $ZEROSSL_HTTP_FV_PORT default_server;
    listen [::]:$ZEROSSL_HTTP_FV_PORT default_server;
    location $ZEROSSL_HTTP_FV_PATH {
        return 200 '$file_content';
    }
}
EOF

"$nginx_bin" -t
"$nginx_bin"