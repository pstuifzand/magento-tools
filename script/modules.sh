#!/bin/bash
find app/code/ -mindepth 3 -maxdepth 3 -type d | grep -v app/code/core | sed 's#app/code/##'
