#!/bin/bash

set -e

MODULENAME="$1"
URINAME=`echo "$MODULENAME" | awk '{print tolower($0)}'`
MODULEDIR=`echo -n "$1" | sed -e 's/_/\//'`
BASE=`dirname $0`

FILENAME="app/code/community/${MODULEDIR}/etc/config.xml"
EVENT="$2"

METHOD=`echo "${EVENT}" | perl -pe 'chomp;s/_([a-z])/uc($1)/gce;$_=ucfirst;'`

xmlstarlet tr $BASE/xml/event_add.xslt \
    -s event_name="$EVENT" \
    -s observer_name="${URINAME}_$EVENT" \
    -s class_name="$URINAME/observer" \
    -s method_name="event$METHOD" \
    $FILENAME | xmlstarlet fo -s 4 - > ${FILENAME}.tmp

mv ${FILENAME}.tmp $FILENAME
