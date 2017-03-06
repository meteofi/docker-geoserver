#!/bin/bash
set -e

if [ "$1" = 'geoserver' ]; then
    exec /usr/share/geoserver/bin/startup.sh
fi

exec "$@"
