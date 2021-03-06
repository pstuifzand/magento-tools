#!/bin/bash
root=`git rev-parse --show-toplevel`
module=${1:-`current-module`}
dir=`echo $module | sed -e 's#_#/#'`
version=`xmlstarlet sel -t -v /config/modules/$module/version  $root/app/code/community/$dir/etc/config.xml`
next_version=`echo $version | perl -pE '($a,$b,$c)=m{(\d+)\.(\d+)\.(\d+)}; $b++; $_="$a.$b.$c"'`
echo $next_version
