FROM curlimages/curl:latest AS downloader

ARG TARGETARCH
ARG VERSION="v1.0.1"

RUN curl -L -o /tmp/zerossl-ip-cert.tar.gz https://github.com/tinkernels/zerossl-ip-cert/releases/download/${VERSION}/zerossl-ip-cert-linux-${TARGETARCH}.tar.gz && \
    mkdir -p /tmp/zerossl-ip-cert && \
    tar --strip-components=2 -xzf /tmp/zerossl-ip-cert.tar.gz -C /tmp/zerossl-ip-cert && \
    echo "Contents of /tmp/zerossl-ip-cert:" && ls -l /tmp/zerossl-ip-cert && \
    rm -f /tmp/zerossl-ip-cert.tar.gz

FROM registry.kyzdt.com/tools/cronjob:nginx

RUN apk --no-cache add ca-certificates curl && \
    curl -s -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    curl -L -o glibc-2.34-r0.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk && \
    apk add --no-cache --force-overwrite glibc-2.34-r0.apk && \
    rm -f glibc-2.34-r0.apk && \
    rm -rf /var/cache/apk/*

COPY --from=downloader /tmp/zerossl-ip-cert/zerossl-ip-cert /usr/local/bin/zerossl-ip-cert

RUN chmod +x /usr/local/bin/zerossl-ip-cert

ENV EXEC_CRON_UNIT=day \
    EXEC_CRON_UNMBER=10 \
    RUN_ON_STARTUP=true \
    LOCAL_EXEC=true
    
COPY hook /hook
COPY scripts/999-task.sh /cron_scripts/999-task.sh
COPY scripts/generate_config.sh /entrypoints.d/001-generate_config.sh
COPY scripts/docker-action /usr/local/bin