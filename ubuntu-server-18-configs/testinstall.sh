#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ "$(hostname)" == "sol.labic" ]; then
   echo "Jamais rode isso no SOL!" 1>&2
   exit 1
fi


echo "nunca rode isso no sol"
