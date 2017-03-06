# GeoServer
GeoServer is a OGC compliant implementation of a number of open standards such as Web Feature Service (WFS), Web Map Service (WMS), and Web Coverage Service (WCS).

Additional formats and publication options are available including Web Map Tile Service (WMTS) and extensions for Catalogue Service (CSW) and Web Processing Service (WPS).

This docker image uses openJDK 1.8, native JAI, ImageIO and Marlin Renderer.

Included plugins: Image Pyramid, GRIB, NetCDF, CSS Styling and WPS

## Run
```
docker run -d -p 8080:8080  meteofi/geoserver
```
Admin interface: http://local-ip:8080/geoserver/web/

## Run with custom GeoServer data directory
```
docker run -d --restart=always --name geoserver -p 80:8080 \
 -v $HOME/geoserver:/usr/share/geoserver/data_dir meteofi/geoserver
```

The default administration credentials are:
* Username: admin
* Password: geoserver
