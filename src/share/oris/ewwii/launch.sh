#!/bin/bash

# or with the correct path
CFG=/usr/share/oris/ewwii/
PLUGIN="/usr/lib/oris/plugins/liboris_ewwii_plugins.so"

if [[ ! -f "$PLUGIN" ]]; then
  MSG="oris_ewwii_plugins is not installed! Skipping ewwii bar opening..."
  echo "$MSG"
  notify-send "$MSG"
  exit 1
fi

ewwii daemon -c "$CFG" &
ewwii set-plugin "$PLUGIN" -c "$CFG"
ewwii open bar -c "$CFG"
ewwii open time -c "$CFG"
