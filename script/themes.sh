#!/bin/bash

root=`git rev-parse --show-toplevel`

if [ "$root" ]
then
    find $root/app/design/frontend -mindepth 2 -maxdepth 2 -type d | sed "s#$root/app/design/frontend/##"
fi
