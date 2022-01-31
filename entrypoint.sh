#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    exec /usr/sbin/privoxy --user privoxy /etc/privoxy/config &
    exec /usr/local/bin/tor
fi

exec "$@"
