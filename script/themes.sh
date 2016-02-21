#!/bin/bash
cd /var/www/html/magento/
find app/design/frontend -mindepth 2 -maxdepth 2 -type d | sed 's/app\/design\/frontend\///'
