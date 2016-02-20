#!/bin/bash
FILE=$1
echo $FILE | sed -e 's/app\/design\/frontend\///' | perl -pe 'm/^(\w+\/\w+)/; $_=$1."\n";'
