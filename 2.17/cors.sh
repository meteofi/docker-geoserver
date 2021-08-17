#!/bin/bash
sed -i $'/<\/web-app>/{e cat cors.xml\n}' $CATALINA_HOME/conf/web.xml
