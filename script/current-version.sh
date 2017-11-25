#!/bin/bash
root=`git rev-parse --show-toplevel`
module=${1:-`current-module`}
dir=`echo $module | sed -e 's#_#/#'`
version=`xmlstarlet sel -t -v /config/modules/$module/version  $root/app/code/community/$dir/etc/config.xml`
echo $version
