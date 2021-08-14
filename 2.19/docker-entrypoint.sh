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
    if [ -n "$LETSENCRYPT_DOMAIN" ] && [ -n "$LETSENCRYPT_EMAIL" ]; then
      certbot --config-dir . --logs-dir /usr/local/tomcat/logs --work-dir /usr/local/tomcat/ --agree-tos -m $LETSENCRYPT_EMAIL -n certonly --standalone -d $LETSENCRYPT_DOMAIN
      cp -f /usr/local/tomcat/live/$LETSENCRYPT_DOMAIN/* /usr/local/tomcat/conf/
    fi

    exec /usr/local/tomcat/bin/catalina.sh run
fi

exec "$@"
