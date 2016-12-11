#!/bin/bash

root=`git rev-parse --show-toplevel`

if [ "$root" ]
then
    xmlstarlet sel -t -v /config/modules/$1/codePool $root/app/etc/modules/$1.xml
    echo
fi
