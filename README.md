# torproxy with with nyx, obfs4proxy and privoxy

## build

- `docker build -t jipp13/torproxy .`
- `docker build -t jipp13/torproxy --build-arg ALPINE_VERSION=3.12.3 .`
- `docker build -t jipp13/torproxy --build-arg ALPINE_VERSION=3.12.3 --build-arg TOR_VERSION=0.4.6.9 .`

## torrc

- `docker run -it --rm jipp13/torproxy cat /usr/local/etc/tor/torrc.sample`

## nyx

- `docker exec -it tor su - tor -c nyx`

### docker-compose

```bash
networks:
  tor:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: br-tor
    enable_ipv6: true
    ipam:
      config:
      - subnet: 192.168.5.0/24
      - subnet: fd00:0:0:5::/64
      driver: default
    name: tor
services:
  tor:
    container_name: tor
    environment:
      TZ: Europe/Berlin
    hostname: tor
    image: jipp13/torproxy:latest
    labels:
      docker.group: tor
    networks:
      tor: null
    ports:
    - protocol: tcp
      published: 8118
      target: 8118
    - protocol: tcp
      published: 9001
      target: 9001
    restart: unless-stopped
    volumes:
    - /docker/tor/etc:/usr/local/etc/tor:rw
    - /docker/tor/lib:/usr/local/var/lib/tor:rw
version: '3'
```
