#!/bin/bash

MODULENAME="$1"
URINAME=`echo "$MODULENAME" | awk '{print tolower($0)}'`
MODULEDIR=`echo -n "$1" | sed -e 's/_/\//'`
BASE=`dirname $0`

mkdir -p app/etc/modules
mkdir -p app/code/community/$MODULEDIR/{Helper,Block,Model,etc,sql,controllers}
xmlstarlet tr $BASE/module_create.xslt -s ModuleName="$MODULENAME" $BASE/module_new.xml > app/etc/modules/$MODULENAME.xml
xmlstarlet tr $BASE/config_create.xslt -s ModuleName="$MODULENAME" -s UriName="$URINAME" $BASE/config_new.xml > app/code/community/$MODULEDIR/etc/config.xml
