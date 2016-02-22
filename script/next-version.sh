#!/bin/bash
module="$1"
dir=`echo $1 | sed -e 's#_#/#'`
version=`xmlstarlet sel -t -v /config/modules/$1/version  app/code/community/$dir/etc/config.xml`
next_version=`echo $version | perl -pE '($a,$b,$c)=m{(\d+)\.(\d+)\.(\d+)}; $b++; $_="$a.$b.$c"'`
echo $next_version
