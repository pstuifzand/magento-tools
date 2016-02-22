#!/bin/bash

module="$1"
dir=`echo $1 | sed -e 's#_#/#'`
next_version=`next-version.sh $module`

xmlstarlet ed -L -u /config/modules/$module/version -v $next_version \
    app/code/community/$dir/etc/config.xml

