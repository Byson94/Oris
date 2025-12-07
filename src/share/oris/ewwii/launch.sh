#!/bin/bash

# or with the correct path
CFG=/usr/share/oris/ewwii/

# Setup theme
mkdir -p "$HOME/.local/share/oris"
if [ ! -e "$HOME/.local/share/oris/colors.scss" ]; then
    cat "$CFG/ewwii_backup_theme.scss" > "$HOME/.local/share/oris/colors.scss"
fi

if [ ! -e "$HOME/.local/share/oris/style_settings.scss" ]; then
    cat "$CFG/ewwii_backup_settings.scss" > "$HOME/.local/share/oris/style_settings.scss"
fi

ewwii daemon -c "$CFG" &
ewwii open bar -c "$CFG"
ewwii open time -c "$CFG"