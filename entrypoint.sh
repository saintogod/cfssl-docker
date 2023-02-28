#!/bin/sh

# Initialize database
if [ ! -f "${CA_CERTS}/certs.db" ]; then
    cp "${HOME}/certs.db" "${CA_CERTS}/certs.db"
fi

# Run service
# Serving OCSP
/usr/bin/cfssl ocspserve -address=0.0.0.0 -port=8889 \
    -db-config "${CA_CONF}/db-config.json" \
    -loglevel 0 &

# Serving Main
exec /usr/bin/cfssl serve -address=0.0.0.0 -port=8888 \
    -config "${CA_CONF}/ca-config.json" \
    -db-config "${CA_CONF}/db-config.json" \
    -ca "${CA_CONF}/ca.pem" \
    -ca-key "${CA_CONF}/ca-key.pem"
