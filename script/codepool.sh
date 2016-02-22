#!/bin/bash
xmlstarlet sel -t -v /config/modules/$1/codePool app/etc/modules/$1.xml
