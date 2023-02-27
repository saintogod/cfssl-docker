#!/bin/sh

# Initialize database
if [ ! -f "${CA_CERTS}/certs.db" ]; then
    cp "${HOME}/certs.db" "${CA_CERTS}/certs.db"
fi

# Run service
exec cfssl ocspserve -port=8889 -db-config db-pg.json
    -db-config "${CA_CONFIG}/db-config.json" \
    -loglevel 0 &

exec /go/bin/cfssl serve -address=0.0.0.0 -port=8888 \
    -config "${CA_CONF}/ca-config.json" \
    -db-config "${CA_CONF}/db-config.json" \
    -ca "${CA_CONF}/ca.pem" \
    -ca-key "${CA_CONF}/ca-key.pem"
