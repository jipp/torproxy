ARG ALPINE_VERSION=latest

FROM alpine:$ALPINE_VERSION

ARG TOR_VERSION="0.4.6.9"
ENV TOR_VERSION=$TOR_VERSION

LABEL maintainer="wolfgang.keller@wobilix.de"

WORKDIR /

RUN apk update && \
    apk add --no-cache --virtual .build-deps build-base libevent-dev openssl-dev zlib-dev libcap-dev zstd-dev xz-dev git go && \
    apk add --no-cache bash tzdata musl py3-pip privoxy curl && \
    apk add --no-cache libevent libgcc libcap zstd-libs && \
    wget https://dist.torproject.org/tor-$TOR_VERSION.tar.gz && \
    wget https://dist.torproject.org/tor-$TOR_VERSION.tar.gz.sha256sum && \
    sed "s/$/  tor-$TOR_VERSION.tar.gz/" tor-$TOR_VERSION.tar.gz.sha256sum > chksum.sha256sum && \
    sha256sum -c chksum.sha256sum && \
    rm chksum.sha256sum && \
    tar xzf tor-$TOR_VERSION.tar.gz && \
    cd tor-$TOR_VERSION && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf tor-$TOR_VERSION* && \
    pip install nyx && \
    git clone https://gitlab.com/yawning/obfs4.git && \
    cd obfs4 && \
    go build -o obfs4proxy/obfs4proxy ./obfs4proxy && \
    cp ./obfs4proxy/obfs4proxy /usr/local/bin && \
    cd .. && \
    rm -rf obfs4 && \
    apk del --no-cache .build-deps && \
    apk add --no-cache libevent libgcc libcap zstd-libs && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache && \
    rm -rf /root/go

RUN adduser tor -D && \
    mkdir -p /usr/local/var/lib/tor && \
    chown tor:tor /usr/local/var/lib/tor && \
    chmod 700 /usr/local/var/lib/tor && \
    cd /etc/privoxy/ && \
    cp config.new config && \
    cp default.action.new default.action && \
    cp default.filter.new default.filter && \
    cp match-all.action.new match-all.action && \
    cp regression-tests.action.new regression-tests.action && \
    cp trust.new trust && \
    cp user.action.new user.action && \
    cp user.filter.new user.filter && \
    chown privoxy:privoxy config default.action default.filter match-all.action regression-tests.action trust user.action user.filter && \
    file='/etc/privoxy/config' && \
    sed -i 's|^\(accept-intercepted-requests\) .*|\1 1|' $file && \
    sed -i '/^listen/s|127\.0\.0\.1||' $file && \
    sed -i '/forward *localhost\//a forward-socks5t / 127.0.0.1:9050 .' $file && \
    sed -i '/^forward-socks5t \//a forward 172.16.*.*/ .' $file && \
    sed -i '/^forward 172\.16\.\*\.\*\//a forward 172.17.*.*/ .' $file && \
    sed -i '/^forward 172\.17\.\*\.\*\//a forward 172.18.*.*/ .' $file && \
    sed -i '/^forward 172\.18\.\*\.\*\//a forward 172.19.*.*/ .' $file && \
    sed -i '/^forward 172\.19\.\*\.\*\//a forward 172.20.*.*/ .' $file && \
    sed -i '/^forward 172\.20\.\*\.\*\//a forward 172.21.*.*/ .' $file && \
    sed -i '/^forward 172\.21\.\*\.\*\//a forward 172.22.*.*/ .' $file && \
    sed -i '/^forward 172\.22\.\*\.\*\//a forward 172.23.*.*/ .' $file && \
    sed -i '/^forward 172\.23\.\*\.\*\//a forward 172.24.*.*/ .' $file && \
    sed -i '/^forward 172\.24\.\*\.\*\//a forward 172.25.*.*/ .' $file && \
    sed -i '/^forward 172\.25\.\*\.\*\//a forward 172.26.*.*/ .' $file && \
    sed -i '/^forward 172\.26\.\*\.\*\//a forward 172.27.*.*/ .' $file && \
    sed -i '/^forward 172\.27\.\*\.\*\//a forward 172.28.*.*/ .' $file && \
    sed -i '/^forward 172\.28\.\*\.\*\//a forward 172.29.*.*/ .' $file && \
    sed -i '/^forward 172\.29\.\*\.\*\//a forward 172.30.*.*/ .' $file && \
    sed -i '/^forward 172\.30\.\*\.\*\//a forward 172.31.*.*/ .' $file && \
    sed -i '/^forward 172\.31\.\*\.\*\//a forward 10.*.*.*/ .' $file && \
    sed -i '/^forward 10\.\*\.\*\.\*\//a forward 192.168.*.*/ .' $file && \
    sed -i '/^forward 192\.168\.\*\.\*\//a forward 127.*.*.*/ .' $file && \
    sed -i '/^forward 127\.\*\.\*\.\*\//a forward localhost/ .' $file

EXPOSE 8118 9001
VOLUME ["/usr/local/etc/tor", "/usr/local/var/lib/tor"]
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/entrypoint.sh"]

HEALTHCHECK --interval=60s --timeout=15s --start-period=20s CMD curl -sx localhost:8118 'https://check.torproject.org/' | grep -qm1 Congratulations
