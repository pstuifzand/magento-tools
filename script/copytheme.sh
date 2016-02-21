#!/bin/bash
set -e

BASE=`dirname $0`
OLDFILE="$1"
OLDTHEME=`$BASE/filetheme.sh $OLDFILE`
THEME=`$BASE/themes.sh | fzf --header="Select Theme"`
NEWFILE=`echo $OLDFILE | sed -e "s#$OLDTHEME#$THEME#"`

DIR=`dirname $NEWFILE`

mkdir -p $DIR
cp "$OLDFILE" "$NEWFILE"

echo Copied $OLDFILE to $NEWFILE
