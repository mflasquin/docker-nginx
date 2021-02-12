#!/bin/bash

[ "$DEBUG" = "true" ] && set -x

chown -R mflasquin:mflasquin $PROJECT_ROOT
chown -R mflasquin:mflasquin /home/mflasquin

VHOST_FILE="/etc/nginx/conf.d/default.conf"
[ ! -z "${PROJECT_ROOT}" ] && sed -i "s#!PROJECT_ROOT!#${PROJECT_ROOT}#" $VHOST_FILE

#CHANGE UID IF NECESSARY
if [ ! -z "$MFLASQUIN_UID" ]
then
  echo "change mflasquin uuid"
  usermod -u $MFLASQUIN_UID mflasquin
fi

#INSTALL PAGESPEED
if [ "$USE_PAGESPEED" = "true" ]
then
  if ! grep "ngx_pagespeed.so" /etc/nginx/nginx.conf
  then
    sed -i '1s#^#load_module modules/ngx_pagespeed.so;\n#' /etc/nginx/nginx.conf
  fi
fi

# SET VHOSTS
if [ "$PROJECT_TYPE" = "magento" ]
then
  VHOST_FILE="/etc/nginx/conf.d/magento.conf"
  [ ! -z "${PROJECT_ROOT}" ] && sed -i "s#!MAGENTO_ROOT!#${PROJECT_ROOT}#" $VHOST_FILE
  rm /etc/nginx/conf.d/default.conf
fi

if [ "$PROJECT_TYPE" != "magento" ]
then
  rm /etc/nginx/conf.d/magento.conf
fi

if [ "$PROJECT_TYPE" = "magento2" ]
then
  VHOST_FILE="/etc/nginx/conf.d/magento2.conf"
  [ ! -z "${PROJECT_ROOT}" ] && sed -i "s#!MAGENTO_ROOT!#${PROJECT_ROOT}#" $VHOST_FILE
  [ ! -z "${MAGENTO_RUN_MODE}" ] && sed -i "s/!MAGENTO_RUN_MODE!/${MAGENTO_RUN_MODE}/" $VHOST_FILE
  rm /etc/nginx/conf.d/default.conf
fi

if [ "$PROJECT_TYPE" != "magento2" ]
then
  rm /etc/nginx/conf.d/magento2.conf
fi

if [ "$PROJECT_TYPE" = "wordpress" ]
then
  VHOST_FILE="/etc/nginx/conf.d/wordpress.conf"
  [ ! -z "${PROJECT_ROOT}" ] && sed -i "s#!PROJECT_ROOT!#${PROJECT_ROOT}#" $VHOST_FILE
  rm /etc/nginx/conf.d/default.conf
fi

if [ "$PROJECT_TYPE" != "wordpress" ]
then
  rm /etc/nginx/conf.d/wordpress.conf
fi

if [ "$PROJECT_TYPE" = "sf4" ]
then
  VHOST_FILE="/etc/nginx/conf.d/sf4.conf"
  [ ! -z "${PROJECT_ROOT}" ] && sed -i "s#!PROJECT_ROOT!#${PROJECT_ROOT}#" $VHOST_FILE
  rm /etc/nginx/conf.d/default.conf
fi

if [ "$PROJECT_TYPE" != "sf4" ]
then
  rm /etc/nginx/conf.d/sf4.conf
fi

if [ "$PROJECT_TYPE" = "prestashop" ]
then
  VHOST_FILE="/etc/nginx/conf.d/prestashop.conf"
  [ ! -z "${PROJECT_ROOT}" ] && sed -i "s#!PROJECT_ROOT!#${PROJECT_ROOT}#" $VHOST_FILE
  rm /etc/nginx/conf.d/default.conf
fi

if [ "$PROJECT_TYPE" != "prestashop" ]
then
  rm /etc/nginx/conf.d/prestashop.conf
fi

[ ! -z "${UPLOAD_MAX_FILESIZE}" ] && sed -i "s/!UPLOAD_MAX_FILESIZE!/${UPLOAD_MAX_FILESIZE}/" $VHOST_FILE
[ ! -z "${FPM_HOST}" ] && sed -i "s/!FPM_HOST!/${FPM_HOST}/" $VHOST_FILE
[ ! -z "${FPM_PORT}" ] && sed -i "s/!FPM_PORT!/${FPM_PORT}/" $VHOST_FILE

# Check if the nginx syntax is fine, then launch.
nginx -t

exec "$@"
