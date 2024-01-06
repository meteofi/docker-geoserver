#/bin/sh

if [ -z "$1" ]; then 
    REST=http://localhost:8080/geoserver/rest
else 
    REST=$1
fi

DEFAULT_PASSWORD=$(openssl rand -base64 12)
GEOSERVER_ADMIN_USER=${GEOSERVER_ADMIN_USER:-admin}
GEOSERVER_ADMIN_PASSWORD=${GEOSERVER_ADMIN_PASSWORD:-$DEFAULT_PASSWORD}
GEOSERVER_WMS_TITLE=${GEOSERVER_WMS_TITLE:-GeoServer}

function api {
    echo $1 $REST$2?$4
    curl -u $GEOSERVER_ADMIN_USER:$GEOSERVER_ADMIN_PASSWORD -X $1 -H  "Content-type: text/xml"  -d "$3" $REST$2?$4
    echo
}

# Wait for GeoServer to start
sleep 10

while [ "$(curl -s --retry-connrefused --retry 100 -I http://localhost:8080/geoserver/web/ 2>&1 |grep 200)" == "" ];do
  echo "Waiting for GeoServer to be Up and running"
done

if [ -n "$GEOSERVER_ADMIN_PASSWORD" ]; then
    curl -H "Authorization: basic YWRtaW46Z2Vvc2VydmVy" -X PUT http://localhost:8080/geoserver/rest/security/self/password -H  "accept: application/json" -H  "content-type: application/json" -d "{  \"newPassword\": \"$GEOSERVER_ADMIN_PASSWORD\"}"
    cat << EOF
    
    ############################################################################
    
     Login with credentials: $GEOSERVER_ADMIN_USER / $GEOSERVER_ADMIN_PASSWORD
    
    ############################################################################

EOF
    sleep 10
    api PUT  /security/masterpw "<masterPassword><oldMasterPassword>geoserver</oldMasterPassword><newMasterPassword>$GEOSERVER_ADMIN_PASSWORD</newMasterPassword></masterPassword>"
fi


if [ -n "$GEOSERVER_PROXY_BASE_URL" ]; then   
    api PUT  /settings "<global><settings><proxyBaseUrl>$GEOSERVER_PROXY_BASE_URL</proxyBaseUrl></settings></global>"
fi

if [ -n "$GEOSERVER_WMS_TITLE" ]; then   
    api PUT  /services/wms/settings "<wms><title>$GEOSERVER_WMS_TITLE</title><abstrct>$GEOSERVER_WMS_ABSTRACT</abstrct></wms>"
fi

if [ -n "$GEOSERVER_WORKSPACE" ]; then
    api POST /workspaces "<workspace><name>$GEOSERVER_WORKSPACE</name></workspace>"
fi

if [ -n "$GEOSERVER_DATASTORE_DB" ]; then
    api POST /workspaces/$GEOSERVER_WORKSPACE/datastores "<dataStore><name>${GEOSERVER_DATASTORE_DB}-db</name><connectionParameters><host>$GEOSERVER_DATASTORE_DB_HOST</host><port>5432</port><database>$GEOSERVER_DATASTORE_DB</database><user>$GEOSERVER_DATASTORE_DB_USER</user><passwd>$GEOSERVER_DATASTORE_DB_PASSWORD</passwd><dbtype>postgis</dbtype></connectionParameters></dataStore>"
fi

# Touch file to indicate configuration is done
touch $GEOSERVER_DATA_DIR/firstrun.done
