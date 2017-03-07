FROM openjdk:8-jre
MAINTAINER mikko@meteo.fi

ENV GEOSERVER_HOME /usr/share/geoserver
#ENV GEOSERVER_DATA_DIR /data/geoserver
ENV JAVA_OPTS -Xbootclasspath/a:${JAVA_HOME}/jre/lib/ext/marlin-0.7.4-Unsafe.jar -Xbootclasspath/p:${JAVA_HOME}/jre/lib/ext/marlin-0.7.4-Unsafe-sun-java2d.jar -Dsun.java2d.renderer=org.marlin.pisces.PiscesRenderingEngine

RUN apt-get update && apt-get install -y --no-install-recommends libnetcdfc++4 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Get native JAI, ImageIO and Marlin Renderer
RUN \
    cd $JAVA_HOME && \
    wget http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64-jre.bin && \
    echo "yes" | sh jai-1_1_3-lib-linux-amd64-jre.bin && \
    rm jai-1_1_3-lib-linux-amd64-jre.bin && \
    # ImageIO
    cd $JAVA_HOME && \
    export _POSIX2_VERSION=199209 &&\
    wget http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64-jre.bin && \
    echo "yes" | sh jai_imageio-1_1-lib-linux-amd64-jre.bin && \
    rm jai_imageio-1_1-lib-linux-amd64-jre.bin && \
    # Get Marlin Renderer
    cd $JAVA_HOME/lib/ext/ && \
    wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.7.4_2/marlin-0.7.4-Unsafe.jar && \
    wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.7.4_2/marlin-0.7.4-Unsafe-sun-java2d.jar

#
# GEOSERVER INSTALLATION
#
ENV GEOSERVER_VERSION 2.9.4

# Get GeoServer
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-bin.zip -O ~/geoserver.zip && \
    unzip ~/geoserver.zip -d /usr/share && mv -v /usr/share/geoserver* /usr/share/geoserver && \
    rm ~/geoserver.zip && \
    # Remove old JAI from geoserver
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_codec-1.1.3.jar && \
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_core-1.1.3.jar && \
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/jai_imageio-1.1.jar

# Get GRIB plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-grib-plugin.zip -O ~/geoserver-grib-plugin.zip && \
    unzip -o ~/geoserver-grib-plugin.zip -d /usr/share/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-grib-plugin.zip

# Get Image Pyramid plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-pyramid-plugin.zip -O ~/geoserver-pyramid-plugin.zip && \
    unzip -o ~/geoserver-pyramid-plugin.zip -d /usr/share/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-pyramid-plugin.zip

# Get Image NetCDF plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-netcdf-plugin.zip -O ~/geoserver-netcdf-plugin.zip && \
    unzip -o ~/geoserver-netcdf-plugin.zip -d /usr/share/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-netcdf-plugin.zip

# Get CSS Styling plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-css-plugin.zip -O ~/geoserver-css-plugin.zip && \
    unzip -o ~/geoserver-css-plugin.zip -d /usr/share/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-css-plugin.zip

# Get WPS plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-wps-plugin.zip -O ~/geoserver-wps-plugin.zip && \
    unzip -o ~/geoserver-wps-plugin.zip -d /usr/share/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-wps-plugin.zip

# Expose GeoServer's default port
EXPOSE 8080

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f "http://localhost:8080/geoserver/ows?service=wms&version=1.3.0&request=GetCapabilities" || exit 1

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["geoserver"]

