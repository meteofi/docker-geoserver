ARG TOMCAT_VERSION="9.0-jre11"

FROM docker.io/tomcat:$TOMCAT_VERSION
LABEL maintainer "Mikko Rauhala <mikko@meteo.fi>"

ARG GEOSERVER_VERSION="2.19.7"
ARG GEOSERVER_DATA_DIR="/data/geoserver"
ARG GEOSERVER_PLUGINS="css grib netcdf pyramid vectortiles wps ysld"
ARG GEOSERVER_FONTS="lato notosans opensans poppins roboto ubuntu"

ENV GEOSERVER_FONTS=${GEOSERVER_FONTS} \
    GEOSERVER_VERSION=${GEOSERVER_VERSION} \
    GEOSERVER_DATA_DIR=${GEOSERVER_DATA_DIR} \
    GEOSERVER_PLUGINS=${GEOSERVER_PLUGINS} \
    GEOSERVER_NODE_OPTS='id:$host_name' \
    GEOWEBCACHE_CACHE_DIR='/data/gwc' \
    JAVA_OPTS="-Xms128m -XX:SoftRefLRUPolicyMSPerMB=36000 -XX:+UseG1GC" \
    UMASK=002

# persistent / runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends libnetcdf-c++4-1 curl unzip fnt xz-utils binutils && rm -r /var/lib/apt/lists/*

# Install Google Fonts
RUN \
    fnt update  && \
    for FONT in $GEOSERVER_FONTS; \
    do \
        fnt install "${FONT}" ; \
    done && \
    fnt list

# Install GeoServer
RUN curl -sS -L -O https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-war.zip && \
    unzip -d $CATALINA_HOME/webapps/ geoserver-$GEOSERVER_VERSION-war.zip geoserver.war && \
    unzip -d $CATALINA_HOME/webapps/geoserver $CATALINA_HOME/webapps/geoserver.war && \
    rm geoserver-$GEOSERVER_VERSION-war.zip $CATALINA_HOME/webapps/geoserver.war && \
    rm -rf $CATALINA_HOME/webapps/geoserver/data/workspaces/tiger $CATALINA_HOME/webapps/geoserver/data/workspaces/nurc $CATALINA_HOME/webapps/geoserver/data/workspaces/sf $CATALINA_HOME/webapps/geoserver/data/workspaces/topp $CATALINA_HOME/webapps/geoserver/data/layergroups/* && \
    mkdir -p $GEOSERVER_DATA_DIR $GEOWEBCACHE_CACHE_DIR && \
    mv $CATALINA_HOME/webapps/geoserver/data/* $GEOSERVER_DATA_DIR && \
    sed -e 's/>PARTIAL-BUFFER2</>SPEED</g' -i $CATALINA_HOME/webapps/geoserver/WEB-INF/web.xml && \
    chgrp -R 0 $CATALINA_HOME $GEOWEBCACHE_CACHE_DIR $GEOSERVER_DATA_DIR && \
    chmod -R g=u $CATALINA_HOME $GEOWEBCACHE_CACHE_DIR $GEOSERVER_DATA_DIR

# Install GeoServer Plugins
RUN for PLUGIN in ${GEOSERVER_PLUGINS}; \
    do \
      curl -sS -L -O https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip && \
      unzip -o geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -d $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ && \
      rm geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip ; \
    done

# Expose GeoServer's default port
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s\
    CMD curl -f "http://localhost:8080/geoserver/ows?service=wms&version=1.3.0&request=GetCapabilities" || exit 1

# Enable CORS
RUN sed -i '\:</web-app>:i \
    <filter>\n \
        <filter-name>CorsFilter</filter-name>\n \
        <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>\n \
        <init-param>\n \
            <param-name>cors.allowed.origins</param-name>\n \
            <param-value>*</param-value>\n \
        </init-param>\n \
    </filter>\n \
    <filter-mapping>\n \
        <filter-name>CorsFilter</filter-name>\n \
        <url-pattern>/*</url-pattern>\n \
    </filter-mapping>' $CATALINA_HOME/conf/web.xml

RUN chmod -R g=u /etc/passwd /var/log

COPY docker-entrypoint.sh first-run-config.sh /

### Containers should NOT run as root as a good practice
USER 101010

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["geoserver"]

