FROM openjdk:8-jre
LABEL maintainer "Mikko Rauhala <mikko@meteo.fi>"

# persistent / runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends libnetcdf-c++4 && rm -r /var/lib/apt/lists/*

ENV NOTO_FONTS="NotoSans-unhinted NotoSerif-unhinted NotoMono-hinted" \
    GOOGLE_FONTS="Open%20Sans Roboto Lato Ubuntu" \
    GEOSERVER_VERSION="2.11.4" \
    GEOSERVER_PLUGINS="css grib netcdf pyramid vectortiles wps ysld" \
    GEOSERVER_HOME="/usr/share/geoserver" \
    GEOSERVER_NODE_OPTS='id:$host_name' \
    JAVA_OPTS="-Xbootclasspath/a:${JAVA_HOME}/jre/lib/ext/marlin-0.7.4-Unsafe.jar -Xbootclasspath/p:${JAVA_HOME}/jre/lib/ext/marlin-0.7.4-Unsafe-sun-java2d.jar -Dsun.java2d.renderer=org.marlin.pisces.PiscesRenderingEngine -XX:+UseG1GC"
# Install Google Noto fonts
RUN mkdir -p /usr/share/fonts/truetype/noto && \
    for FONT in ${NOTO_FONTS}; \
    do \
        wget -nv https://noto-website-2.storage.googleapis.com/pkgs/${FONT}.zip && \
    	unzip -o ${FONT}.zip -d /usr/share/fonts/truetype/noto && \
    	rm -f ${FONT}.zip ; \
    done

# Install Google Fonts
RUN \
    for FONT in $GOOGLE_FONTS; \
    do \
        mkdir -p /usr/share/fonts/truetype/${FONT} && \
        wget -nv -O ${FONT}.zip "https://fonts.google.com/download?family=${FONT}" && \
    	unzip -o ${FONT}.zip -d /usr/share/fonts/truetype/${FONT} && \
    	rm -f ${FONT}.zip ; \
    done

# Install native JAI, ImageIO and Marlin Renderer
RUN \
    cd $JAVA_HOME && \
    wget -nv http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64-jre.bin && \
    echo "yes" | sh jai-1_1_3-lib-linux-amd64-jre.bin && \
    rm jai-1_1_3-lib-linux-amd64-jre.bin && \
    # ImageIO
    cd $JAVA_HOME && \
    export _POSIX2_VERSION=199209 &&\
    wget -nv http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64-jre.bin && \
    echo "yes" | sh jai_imageio-1_1-lib-linux-amd64-jre.bin && \
    rm jai_imageio-1_1-lib-linux-amd64-jre.bin && \
    # Get Marlin Renderer
    cd $JAVA_HOME/lib/ext/ && \
    wget -nv https://github.com/bourgesl/marlin-renderer/releases/download/v0.7.4_2/marlin-0.7.4-Unsafe.jar && \
    wget -nv https://github.com/bourgesl/marlin-renderer/releases/download/v0.7.4_2/marlin-0.7.4-Unsafe-sun-java2d.jar && \
    wget -nv https://jdbc.postgresql.org/download/postgresql-42.0.0.jar

#
# GEOSERVER INSTALLATION
#

# Install GeoServer
RUN wget -nv http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-bin.zip && \
    unzip geoserver-$GEOSERVER_VERSION-bin.zip -d /usr/share && mv -v /usr/share/geoserver* $GEOSERVER_HOME && \
    rm geoserver-$GEOSERVER_VERSION-bin.zip && \
    sed -e 's/>PARTIAL-BUFFER2</>SPEED</g' -i $GEOSERVER_HOME/webapps/geoserver/WEB-INF/web.xml && \
    # Remove old JAI from geoserver
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_codec-*.jar && \
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_core-*jar && \
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_imageio-*.jar && \
    echo "--module=servlets" >> $GEOSERVER_HOME/start.ini && \
    echo "--module=jndi"    >> $GEOSERVER_HOME/start.ini && \
    echo '[depend]\nserver\nplus\nutil\n[xml]\ndata_dir/jetty-jndi.xml\n[lib]\nlib/jetty-jndi-${jetty.version}.jar' > $GEOSERVER_HOME/modules/jndi.mod && \
    echo '[depend]\nserver\n[lib]\nlib/jetty-plus-${jetty.version}.jar' > $GEOSERVER_HOME/modules/plus.mod && \
    echo '[depend]\nserver\n[lib]\nlib/jetty-util-${jetty.version}.jar' > $GEOSERVER_HOME/modules/util.mod && \
    echo '[depend]\nserver\n[lib]\nlib/jetty-servlets-${jetty.version}.jar' > $GEOSERVER_HOME/modules/servlets.mod && \
    wget -nv -P $GEOSERVER_HOME/lib/ http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-plus/9.2.13.v20150730/jetty-plus-9.2.13.v20150730.jar && \
    wget -nv -P $GEOSERVER_HOME/lib/ http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-jndi/9.2.13.v20150730/jetty-jndi-9.2.13.v20150730.jar && \
    wget -nv -P $GEOSERVER_HOME/lib/ http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-servlets/9.2.13.v20150730/jetty-servlets-9.2.13.v20150730.jar && \
    wget -nv -P $GEOSERVER_HOME/lib/ http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util/9.2.13.v20150730/jetty-util-9.2.13.v20150730.jar && \
    perl -i -0777 -pe 's/<!--\s*?(<filter.*?cross-origin.*?\/filter>)\s*?-->/$1/s' $GEOSERVER_HOME/webapps/geoserver/WEB-INF/web.xml && \
    perl -i -0777 -pe 's/<!--\s*?(<filter-mapping.*?cross-origin.*?\/filter-mapping>)\s*?-->/$1/s' $GEOSERVER_HOME/webapps/geoserver/WEB-INF/web.xml

COPY jetty-jndi.xml $GEOSERVER_HOME/data_dir/

# Install GeoServer Plugins
RUN for PLUGIN in ${GEOSERVER_PLUGINS}; \
    do \
      wget -nv http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip && \
      unzip -o geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -d /usr/share/geoserver/webapps/geoserver/WEB-INF/lib/ && \
      rm geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip ; \
    done

# Expose GeoServer's default port
EXPOSE 8080

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f "http://localhost:8080/geoserver/ows?service=wms&version=1.3.0&request=GetCapabilities" || exit 1

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["geoserver"]
