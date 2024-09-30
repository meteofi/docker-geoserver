#!/bin/bash
set -e

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-geoserver}:x:$(id -u):0:${USER_NAME:-geoserver} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

if [ "$1" = 'geoserver' ]; then
  id
  whoami

  # Run configuration if first run
  if [ ! -f $GEOSERVER_DATA_DIR/firstrun.done ]; then
    echo "Fist run for container, starting configuration"
    /first-run-config.sh &
  fi

  # Start tomcat
  exec /usr/local/tomcat/bin/catalina.sh run
fi

exec "$@"
