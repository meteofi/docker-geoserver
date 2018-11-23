FROM docker.io/openjdk:8-jre-slim
LABEL maintainer "Mikko Rauhala <mikko@meteo.fi>"

# persistent / runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends libnetcdf-c++4 curl && rm -r /var/lib/apt/lists/*

ENV NOTO_FONTS="NotoSans-unhinted NotoSerif-unhinted NotoMono-hinted" \
    GOOGLE_FONTS="Open%20Sans Roboto Lato Ubuntu" \
    GEOSERVER_VERSION="2.14.1" \
    GEOSERVER_PLUGINS="css grib imagemosaic-jdbc mongodb netcdf pyramid vectortiles wps ysld" \
    GEOSERVER_HOME="/usr/share/geoserver" \
    GEOSERVER_NODE_OPTS='id:$host_name' \
    JETTY_VERSION="9.4.14.v20181114" \
    JAVA_OPTS="-Xbootclasspath/a:${JAVA_HOME}/jre/lib/ext/marlin-0.9.2-Unsafe.jar -Xbootclasspath/p:${JAVA_HOME}/jre/lib/ext/marlin-0.9.2-Unsafe-sun-java2d.jar -Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine -XX:+UseG1GC -DGEOSERVER_XSTREAM_WHITELIST=org.geoserver.rest.security.xml.JaxbUser"

# Install Google Noto fonts
RUN mkdir -p /usr/share/fonts/truetype/noto && \
    for FONT in ${NOTO_FONTS}; \
    do \
        curl -sS -O https://noto-website-2.storage.googleapis.com/pkgs/${FONT}.zip && \
    	unzip -o ${FONT}.zip -d /usr/share/fonts/truetype/noto && \
    	rm -f ${FONT}.zip ; \
    done

# Install Google Fonts
RUN \
    for FONT in $GOOGLE_FONTS; \
    do \
        mkdir -p /usr/share/fonts/truetype/${FONT} && \
        curl -sS -o ${FONT}.zip "https://fonts.google.com/download?family=${FONT}" && \
    	unzip -o ${FONT}.zip -d /usr/share/fonts/truetype/${FONT} && \
    	rm -f ${FONT}.zip ; \
    done

# Install native JAI
RUN \
    cd $JAVA_HOME && \
    curl -sS -L -O https://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64-jre.bin && \
    echo "yes" | sh jai-1_1_3-lib-linux-amd64-jre.bin && \
    rm jai-1_1_3-lib-linux-amd64-jre.bin

# Install ImageIO
RUN \
    cd $JAVA_HOME && \
    export _POSIX2_VERSION=199209 &&\
    curl -sS -L -O https://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64-jre.bin && \
    echo "yes" | sh jai_imageio-1_1-lib-linux-amd64-jre.bin && \
    rm jai_imageio-1_1-lib-linux-amd64-jre.bin

# Get Marlin Renderer
RUN \
    cd $JAVA_HOME/lib/ext/ && \
    curl -L -sS -O https://github.com/bourgesl/marlin-renderer/releases/download/v0_9_2/marlin-0.9.2-Unsafe.jar && \
    curl -L -sS -O https://github.com/bourgesl/marlin-renderer/releases/download/v0_9_2/marlin-0.9.2-Unsafe-sun-java2d.jar && \
    curl -L -sS -O https://jdbc.postgresql.org/download/postgresql-42.2.5.jar && \
    sed -i 's/^assistive_technologies=/#&/' /etc/java-8-openjdk/accessibility.properties

#
# GEOSERVER INSTALLATION
#




# Install Jetty
RUN curl -sS -L -O https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.zip && \
    unzip jetty-distribution-${JETTY_VERSION}.zip && \
    mv -v jetty-distribution-${JETTY_VERSION} $GEOSERVER_HOME && \
    rm jetty-distribution-${JETTY_VERSION}.zip
# Install GeoServer
RUN curl -sS -L -O http://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-bin.zip && \
    unzip geoserver-$GEOSERVER_VERSION-bin.zip && \
    cp -r --no-target-directory geoserver-$GEOSERVER_VERSION/webapps $GEOSERVER_HOME/webapps && \
    cp -r --no-target-directory geoserver-$GEOSERVER_VERSION/data_dir $GEOSERVER_HOME/data_dir && \
    cp -r --no-target-directory geoserver-$GEOSERVER_VERSION/bin $GEOSERVER_HOME/bin && \
    rm -rf geoserver-$GEOSERVER_VERSION && \
    rm geoserver-$GEOSERVER_VERSION-bin.zip
# Do some adjustments
RUN sed -e 's/>PARTIAL-BUFFER2</>SPEED</g' -i $GEOSERVER_HOME/webapps/geoserver/WEB-INF/web.xml && \
    # Remove old JAI from geoserver
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_codec-*.jar && \
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_core-*jar && \
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_imageio-*.jar && \
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/marlin-*.jar && \
    echo "--module=servlets" >> $GEOSERVER_HOME/start.ini && \
    echo "--module=jndi"    >> $GEOSERVER_HOME/start.ini && \
    perl -i -0777 -pe 's/<!--\s*?(<filter.*?cross-origin.*?\/filter>)\s*?-->/$1/s' $GEOSERVER_HOME/webapps/geoserver/WEB-INF/web.xml && \
    perl -i -0777 -pe 's/<!--\s*?(<filter-mapping.*?cross-origin.*?\/filter-mapping>)\s*?-->/$1/s' $GEOSERVER_HOME/webapps/geoserver/WEB-INF/web.xml

# Install GeoServer Plugins
RUN for PLUGIN in ${GEOSERVER_PLUGINS}; \
    do \
      curl -sS -L -O http://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip && \
      unzip -o geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -d /usr/share/geoserver/webapps/geoserver/WEB-INF/lib/ && \
      rm geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip ; \
    done

COPY jetty-jndi.xml $GEOSERVER_HOME/data_dir/
VOLUME $GEOSERVER_HOME/data_dir/

# Expose GeoServer's default port
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s\
    CMD curl -f "http://localhost:8080/geoserver/ows?service=wms&version=1.3.0&request=GetCapabilities" || exit 1

COPY docker-entrypoint.sh /

RUN mkdir -p $GEOSERVER_HOME && \
    chgrp -R 0 $GEOSERVER_HOME && \
    chmod -R g=u $GEOSERVER_HOME /etc/passwd /var/log

### Containers should NOT run as root as a good practice
USER 101010

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["geoserver"]
