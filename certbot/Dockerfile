FROM certbot/certbot

RUN apk -U upgrade && \
    apk add curl bash iptables ca-certificates e2fsprogs docker && \
    pip install certbot-dns-cloudflare && \
    rm -rf /var/cache/apk/*

COPY ./run.sh /run.sh
