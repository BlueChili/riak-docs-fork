#!/usr/bin/env sh

WATCH="${HUGO_WATCH:=false}"
HUGO_PORT="${HUGO_PORT:=1314}"

echo "HUGO_WATCH:"        $WATCH
echo "HUGO_THEME:"        $HUGO_THEME
echo "HUGO_BASEURL:"      $HUGO_BASEURL
echo "HUGO_PORT:"         $HUGO_PORT
echo "ARGS"               $@

npm install

if [[ $HUGO_WATCH == true ]]; then
  echo "Watching..."
    # add for logging: --log --logFile "/output/log.txt" --verboseLog
    hugo server --watch=true --source="/src" --theme="$HUGO_THEME" --destination="/output" --baseURL="$HUGO_BASEURL" --bind="0.0.0.0" "$@" -p $HUGO_PORT || exit 1
else
  echo "Building one time..."
    hugo --source="/src" --theme="$HUGO_THEME" --destination="/output" --baseURL="$HUGO_BASEURL" "$@" || exit 1
fi

