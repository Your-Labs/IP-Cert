FROM registry.kyzdt.com/tools/cronjob:nginx

COPY bin/amd64/zerossl-ip-cert /usr/local/bin 

RUN apk --no-cache add ca-certificates wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk && \
    apk add --no-cache --force-overwrite glibc-2.34-r0.apk && \
    rm -f glibc-2.34-r0.apk && \
    rm -rf /var/cache/apk/*

ENV EXEC_CRON_UNIT=day \
    EXEC_CRON_UNMBER=10 \
    RUN_ON_STARTUP=true
    
COPY hook /hook
COPY scripts/999-task.sh /cron_scripts/999-task.sh
COPY scripts/docker-action /usr/local/bin 