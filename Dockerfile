ARG ALPINE_VERSION=latest

FROM alpine:$ALPINE_VERSION

ENV TOR_VERSION="0.4.6.9"

LABEL maintainer="wolfgang.keller@wobilix.de"

WORKDIR /

RUN apk add --no-cache --virtual .build-deps build-base libevent-dev openssl-dev zlib-dev libcap-dev zstd-dev xz-dev && \
    apk add --no-cache bash tzdata musl py3-pip && \
    wget https://dist.torproject.org/tor-$TOR_VERSION.tar.gz && \
    tar xzf tor-$TOR_VERSION.tar.gz && \
    cd tor-$TOR_VERSION && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf tor-$TOR_VERSION* && \
    apk del --no-cache .build-deps && \
    apk add --no-cache libevent libgcc libcap zstd-libs && \
    pip install nyx && \
    rm -rf /var/cache/apk/* && \
    adduser tor -D && \
    mkdir -p /usr/local/var/lib/tor && \
    chown tor:tor /usr/local/var/lib/tor && \
    chmod 700 /usr/local/var/lib/tor

EXPOSE 9001 9030 9050
VOLUME ["/usr/local/etc/tor", "/usr/local/var/lib/tor"]
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/tor"]

