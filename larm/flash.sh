#!/bin/bash

# Kommandon för att uppdatera firmware på larmhårdvaran.
#
firmware="larm.hex"

if [ -f $firmware ]; then
    echo "Flashing firmware for larm hardware..."
    echo "atflash" > "/dev/larm"
    sleep 5

    dfu-programmer atmega32u2 erase
    dfu-programmer atmega32u2 flash larm.hex
    dfu-programmer atmega32u2 start
else
    echo "Firmware file $firmware don't exist!"
fi
