# GeoServer
GeoServer is a OGC compliant implementation of a number of open standards such as Web Feature Service (WFS), Web Map Service (WMS), and Web Coverage Service (WCS).

Additional formats and publication options are available including Web Map Tile Service (WMTS) and extensions for Catalogue Service (CSW) and Web Processing Service (WPS).

This docker image uses openJDK 1.8, native JAI, ImageIO and Marlin Renderer.

Included plugins: Image Pyramid, GRIB, NetCDF, CSS Styling, YSLD Styling and WPS

Image follows recommendations in http://docs.geoserver.org/stable/en/user/production/ where applicable.

## Installation
```
docker pull meteofi/geoserver
```
or build it yourself
```
git clone https://github.com/meteofi/docker-geoserver.git
cd docker-geoserver
docker build --rm -t geoserver .
```

## Quick Start
```
docker run -d --name geoserver -p 8080:8080  meteofi/geoserver
```
Admin interface: http://localhost:8080/geoserver/web/

The default administration credentials are:
* Username: admin
* Password: geoserver

## Run with custom GeoServer data directory
```
docker run -d --restart=always --name geoserver -p 80:8080 \
 -v $HOME/geoserver:/usr/share/geoserver/data_dir meteofi/geoserver
```


