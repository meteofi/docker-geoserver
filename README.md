# GeoServer
GeoServer is a OGC compliant implementation of a number of open standards such as Web Feature Service (WFS), Web Map Service (WMS), and Web Coverage Service (WCS).

Additional formats and publication options are available including Web Map Tile Service (WMTS) and extensions for Catalogue Service (CSW) and Web Processing Service (WPS).

### Supported tags and respective **`Dockerfile`** links
* `2.11.0`, `2.11`, `stable`, `latest` ([2.11/Dockerfile](https://github.com/meteofi/docker-geoserver/blob/2.11/Dockerfile))
* `2.10.2`, `2.10`, `maintenance` ([2.10/Dockerfile](https://github.com/meteofi/docker-geoserver/blob/2.10/Dockerfile))
* `2.9.4`, `2.9` ([2.9.4/Dockerfile](https://github.com/meteofi/docker-geoserver/blob/2.9.4/Dockerfile))

### FEATURES
* build from official [OpenJDK 1.8 docker image](https://hub.docker.com/_/openjdk/)
* includes native JAI, ImageIO and Marlin Renderer for better performance
* includes plugins: CSS Styling, GRIB, Image Pyramid, NetCDF, WPS and YSLD Styling 
* includes additional fonts: [Noto](https://www.google.com/get/noto/), [Open Sans](https://fonts.google.com/specimen/Open+Sans), [Roboto](https://fonts.google.com/specimen/Roboto), [Ubuntu](https://fonts.google.com/specimen/Ubuntu) and [Lato](https://fonts.google.com/specimen/Lato) for better labeling
* image follows recommendations in http://docs.geoserver.org/stable/en/user/production/ where applicable
* docker health check
* CORS enabled

### INSTALL
```
docker pull meteofi/geoserver
```

or build it yourself
```
git clone https://github.com/meteofi/docker-geoserver.git
cd docker-geoserver
docker build --rm -t meteofi/geoserver .
```

### QUICK START
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

data_dir must have sufficient permissions for containert to have read write access.

