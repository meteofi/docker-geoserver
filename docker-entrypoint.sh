#!/bin/bash
set -e

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

if [ "$1" = 'geoserver' ]; then
    id
    whoami
    if [ -n "$LETSENCRYPT_DOMAIN" ]; then
      certbot --config-dir . --logs-dir /usr/local/tomcat/logs --work-dir /usr/local/tomcat/ --agree-tos -m mikko@rauhala.net -n certonly --standalone -d $LETSENCRYPT_DOMAIN
      cp -f /usr/local/tomcat/live/$LETSENCRYPT_DOMAIN/* /usr/local/tomcat/conf/
    fi
#    mkdir -p /usr/local/tomcat/webapps/ROOT
#    certbot --config-dir /usr/local/tomcat/ --logs-dir /usr/local/tomcat/logs --work-dir . --agree-tos -m mikko@rauhala.net -n certonly --webroot -w /usr/local/tomcat/webapps/ROOT/ -d pilvi.rauhala.net
    exec /usr/local/tomcat/bin/catalina.sh run
fi

exec "$@"
