#!/bin/bash

# Check if the file exists and back it up
if [ -f /var/www/html/index.html ]; then
  echo "Backing up existing file /var/www/html/index.html"
  mv /var/www/html/index.html /var/www/html/index.html.bak
else
  echo "No file to back up"
fi
