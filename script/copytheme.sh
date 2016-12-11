#!/bin/bash
set -e

root=`git rev-parse --show-toplevel`

BASE=`dirname $0`
OLDFILE="$1"
OLDTHEME=`$BASE/filetheme.sh $OLDFILE`
THEME=`$BASE/themes.sh | fzf --header="Select Theme"`
NEWFILE=`echo $OLDFILE | sed -e "s#$OLDTHEME#$THEME#"`

DIR=`dirname $root/$NEWFILE`

mkdir -p $DIR
cp "$root/$OLDFILE" "$root/$NEWFILE"

echo Copied $OLDFILE to $NEWFILE

git add $root/$NEWFILE
git ci -m "Copied $OLDFILE to $THEME"

