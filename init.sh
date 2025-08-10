#!/bin/bash

. ./secrets

cp larm/larmd-template larm/larmd
chmod +x larm/larmd

# Add DB creds to larmd service
sed -i "s/DBHOST =.*/DBHOST = $DBHOST/" larm/larmd
sed -i "s/DBNAME =.*/DBNAME = $DBNAME/" larm/larmd
sed -i "s/DBUSER =.*/DBUSER = $DBUSER/" larm/larmd
sed -i "s/DBPASS =.*/DBPASS = $DBPASS/" larm/larmd

echo "IMG_NAME='raspios'
LOCALE_DEFAULT='sv_SE.UTF-8'
TARGET_HOSTNAME='larmpi'
KEYBOARD_KEYMAP='se'
KEYBOARD_LAYOUT='Swedish (SE)'
TIMEZONE_DEFAULT='Europe/Stockholm'
FIRST_USER_NAME='$RPI_USER'
FIRST_USER_PASS='$RPI_PASS'
DISABLE_FIRST_BOOT_USER_RENAME=1
ENABLE_SSH=1" > config
