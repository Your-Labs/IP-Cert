FROM registry.kyzdt.com/tools/cronjob:nginx

COPY bin/amd64/zerossl-ip-cert /usr/local/bin 

ENV EXEC_CRON_UNIT=day \
    EXEC_CRON_UNMBER=70 \
    ZEROSSL_HTTP_FV_PORT=80 \