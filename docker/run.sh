#!/usr/bin/env sh

# Based on https://github.com/jojomi/docker-hugo/blob/0.25.1/run.sh

RAKE_GEN_DOWNS="${RAKE_GEN_DOWNS:=false}"
RAKE_GEN_PROJECTS="${RAKE_GEN_PROJECTS:=true}"

echo "RAKE_GEN_DOWNS:"    $RAKE_GEN_DOWNS
echo "RAKE_GEN_PROJECTS:" $RAKE_GEN_PROJECTS
echo "ARGS"               $@

bundle update --bundler
bundle install

if [[ "$RAKE_GEN_DOWNS" != "false" ]]; then
    rake metadata:generate_downloads
fi

if [[ "$RAKE_GEN_PROJECTS" != "false" ]]; then
    rake metadata:generate_projects
fi
