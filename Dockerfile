FROM golang:1.16.15-alpine3.15 as builder

RUN apk add --no-cache git make gcc && git clone https://github.com/cloudflare/cfssl.git /workdir && \
    cd /workdir && \
    make clean && \
    make all
    
FROM alpine:3.15

ENV TINI_VERSION v0.19.0

# Add Tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Run tini
ENTRYPOINT ["/tini", "--"]

# Create cfssl user and group
RUN adduser -h /home/cfssl -s /bin/sh -u 1000 -D cfssl

# CFSSL volume
ENV CA_PATH=/etc/cfssl CA_CONF=/etc/cfssl/conf.d CA_CERTS=/home/cfssl/certs

VOLUME /etc/cfssl/conf.d /home/cfssl/certs

# CFSSL service port
EXPOSE 8888 8889

COPY --from=builder /workdir/bin/ /usr/bin

# Run intermediate CA
ADD entrypoint.sh /

USER cfssl
CMD ["/entrypoint.sh"]
