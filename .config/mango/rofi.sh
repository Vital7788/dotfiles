#!/bin/bash

# Rofi wrapper:
#   - picks a random accent color for the selected item
#   - ages out the drun history

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi3.druncache"
PERCENT=90  # kept per day; floor sits at 50 / (100 - PERCENT) = 5

# an app settles at roughly (uses/day) * 100 / (100 - PERCENT)
decay_drun_history() {
    [ -f "$CACHE" ] || return 0

    # Decay once per day
    [ "$(date -r "$CACHE" +%F)" = "$(date +%F)" ] && return 0

    local lines=() count id
    while read -r count id; do
        [ -n "$id" ] || continue
        # +50 to round half-up instead of truncating
        lines+=("$(( (count * PERCENT + 50) / 100 )) $id")
    done <"$CACHE"

    [ ${#lines[@]} -gt 0 ] || return 0
    printf '%s\n' "${lines[@]}" >"$CACHE"
}

decay_drun_history

colors=("red" "green" "yellow" "blue" "purple" "cyan" "orange" "pink")
color=${colors[$((RANDOM % ${#colors[@]}))]}

rofi -theme-str "*{ selected-fg: @$color; selected-bg: @$color-trans; }" "$@"
