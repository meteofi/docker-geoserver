# GeoServer
GeoServer is a OGC compliant implementation of a number of open standards such as Web Feature Service (WFS), Web Map Service (WMS), and Web Coverage Service (WCS).

Additional formats and publication options are available including Web Map Tile Service (WMTS) and extensions for Catalogue Service (CSW) and Web Processing Service (WPS).

### Supported tags and respective **`Dockerfile`** links
* `2.20.0`, `2.20`, `stable`, `latest` ([2.20/Dockerfile](https://github.com/meteofi/docker-geoserver/blob/master/2.20/Dockerfile))
* `2.19.4`, `2.19`, `maintenance` ([2.19/Dockerfile](https://github.com/meteofi/docker-geoserver/blob/master/2.19/Dockerfile))
* `2.18.5`, `2.18` ([2.18/Dockerfile](https://github.com/meteofi/docker-geoserver/blob/master/2.18/Dockerfile))
* `2.17.5`, `2.17` ([2.17/Dockerfile](https://github.com/meteofi/docker-geoserver/blob/master/2.17/Dockerfile))
* `2.16.5`, `2.16` ([2.16/Dockerfile](https://github.com/meteofi/docker-geoserver/blob/master/2.16/Dockerfile))
* `2.15.5`, `2.15` ([2.15/Dockerfile](https://github.com/meteofi/docker-geoserver/blob/master/2.15/Dockerfile))

### FEATURES
* build from official [Tomcat 9 docker image](https://hub.docker.com/_/tomcat)
* includes plugins: CSS Styling, GRIB, MongoDB, NetCDF, Vector Tiling, WPS and YSLD Styling 
* includes additional fonts: [Noto](https://www.google.com/get/noto/), [Open Sans](https://fonts.google.com/specimen/Open+Sans), [Roboto](https://fonts.google.com/specimen/Roboto), [Ubuntu](https://fonts.google.com/specimen/Ubuntu) and [Lato](https://fonts.google.com/specimen/Lato) for better labeling
* image follows recommendations in http://docs.geoserver.org/stable/en/user/production/ where applicable
* docker health check
* CORS enabled
* runs as any user, OpenShift ready
* Let's Encrypt ready

### INSTALL
```
docker pull meteofi/geoserver
```

or build it yourself
```
git clone https://github.com/meteofi/docker-geoserver.git
cd docker-geoserver
docker build --rm -t meteofi/geoserver 2.19
```

### QUICK START
```
docker run -d --name geoserver -p 8080:8080  meteofi/geoserver
```
Admin interface: http://localhost:8080/geoserver/web/

Check the administration credentials from container output or user GEOSERVER_ADMIN_PASSWORD environmental variable during first run.

## Run with custom GeoServer data directory
```
docker volume create geoserver-storage
docker run -d --name geoserver -p 8080:8080 \
 -v geoserver-storage:/data/geoserver meteofi/geoserver
```

