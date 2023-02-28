FROM golang:1.20-alpine as builder

RUN apk add --no-cache git gcc libc-dev make && \
    git clone https://github.com/cloudflare/cfssl.git /workdir && \
    cd /workdir && \
    make clean && \
    make all
    
FROM alpine:3.17

RUN apk add --no-cache tini && \
    adduser -h /home/cfssl -s /bin/sh -u 1000 -D cfssl && \
    mkdir /etc/cfssl

# Run tini
ENTRYPOINT ["/sbin/tini", "--"]

# CFSSL volume
VOLUME /etc/cfssl/conf.d /home/cfssl/certs

# CFSSL service port
EXPOSE 8888 8889

ENV CA_PATH=/etc/cfssl CA_CONF=/etc/cfssl/conf.d CA_CERTS=/home/cfssl/certs

COPY --from=builder /workdir/bin/ /usr/bin

# Run intermediate CA
ADD entrypoint.sh /

USER cfssl
CMD ["/entrypoint.sh"]
