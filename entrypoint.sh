#!/bin/sh

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
    -ca-key "${CA_CONF}/ca-key.pem" \
    -responder "${CA_CONF}/ocsp.pem" \
    -responder-key "${CA_CONF}/ocsp-key.pem"
