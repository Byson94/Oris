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

# start osd service
old_state=$(pamixer --get-volume)
close_pid=""

render_osd() {
    local vol=$1
    local widget=$2

    if ! ewwii active-windows -c "$CFG" | grep -q "^$widget:"; then
        ewwii open "$widget" -c "$CFG"
    fi

    ewwii update --inject "injected_volume=$vol" -pc "$CFG"

    if [ -n "$close_pid" ] && kill -0 "$close_pid" 2>/dev/null; then
        kill "$close_pid" 2>/dev/null
    fi

    (
        sleep 2
        ewwii close "$widget" -c "$CFG"
    ) &
    close_pid=$!
}

while true; do
    # Exiting if daemon died
    if ! ewwii ping -c "$CFG" >/dev/null 2>&1; then
        echo "Daemon died. Exiting script."
        exit 1
    fi

    current_state=$(pamixer --get-volume)
    if [ "$current_state" != "$old_state" ]; then
        render_osd "$current_state" "volosd"
        old_state="$current_state"
    fi
    sleep 0.2
done
