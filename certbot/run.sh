#!/bin/bash

CERTBOT_DOMAINS="-d *.${MINIO_DOMAIN} -d ${MINIO_DOMAIN}"
ACME_SERVER="https://acme-v02.api.letsencrypt.org/directory"
# ACME_SERVER="https://acme-staging-v02.api.letsencrypt.org/directory"

rm /cloudflare.ini

# not using api token because cloudflare technical issue
# https://github.com/rmbolger/Posh-ACME/issues/176
# echo "dns_cloudflare_api_token = $CLOUDFLARE_API_TOKEN" >> /cloudflare.ini
echo "dns_cloudflare_email = $CLOUDFLARE_EMAIL" >> /cloudflare.ini
echo "dns_cloudflare_api_key = $CLOUDFLARE_API_KEY" >> /cloudflare.ini

chmod 600 /cloudflare.ini

if [ -f "/etc/letsencrypt/live/$MINIO_DOMAIN/fullchain.pem" ]; then
    echo 'renew cert'
    certbot renew
else
    echo 'request cert'
    certbot certonly \
        --agree-tos \
        --non-interactive \
        --manual-public-ip-logging-ok \
        --dns-cloudflare \
        --dns-cloudflare-credentials /cloudflare.ini \
        --dns-cloudflare-propagation-seconds 60 \
        --server $ACME_SERVER \
        --expand \
        -m $CERTBOT_EMAIL \
        $CERTBOT_DOMAINS
fi

echo 'reload nginx'
docker exec -t b2_nginx nginx -s reload
