#!/bin/bash

root=`git rev-parse --show-toplevel`

find $root/app/code/ -mindepth 3 -maxdepth 3 -type d | grep -v $root/app/code/core | sed "s#$root/app/code/##"
