#!/bin/sh
# Hyprland + Noctalia session entry point.
#
# Used by /usr/share/wayland-sessions/hyperland-noctalia.desktop (SDDM), and can
# also be run by hand from a TTY.
#
# --- How this works ---------------------------------------------------------
# This script does NOT start the shell itself. It only tells the compositor
# which shell this session wants, by exporting HYPRLAND_SESSION_SHELL, and then
# hands the session over to Hyprland. The shell is started from inside Hyprland
# by ~/.config/hypr/hyprland/execs.lua on the "hyprland.start" event.
#
# Why: an earlier version started the shell before the compositor, polling
# `hyprctl` until Hyprland answered. That raced the compositor on a cold SDDM
# login and left the session with no shell. A shell started by execs.lua runs as
# a child of a compositor that is already up, so the race cannot happen at all.
#
# History: `caelestia shell -d` used to be autostarted from execs.lua, which
# spawns and supervises `qs` (quickshell). Killing that `qs` after startup took
# the whole session down after ~5 seconds. That autostart is disabled; this
# session uses noctalia instead, started by the same execs.lua hook.

log() {
    # Keep a record of runs; useful when SDDM shows a black screen.
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$HOME/.cache/hyperland-noctalia.log"
}

# --- Re-run inside an existing session --------------------------------------
# If Hyprland is already running we are being re-invoked from a TTY inside the
# live session. In that case there is no compositor to hand over to, so start
# the shell directly and exit.
if hyprctl version >/dev/null 2>&1; then
    log "Hyprland already running, starting noctalia now"
    pkill -x qs 2>/dev/null
    pkill -x quickshell 2>/dev/null
    pkill -x noctalia 2>/dev/null
    sleep 0.5
    if command -v noctalia >/dev/null 2>&1; then
        noctalia -d >>"$HOME/.cache/noctalia.log" 2>&1
        log "noctalia started"
    else
        log "ERROR: noctalia not found in PATH"
    fi
    exit 0
fi

# --- Clear stale shells before the compositor starts ------------------------
# `qs` is a symlink to `quickshell`, so match both names -- `pkill -x qs` alone
# misses a process named `quickshell`.
pkill -x qs 2>/dev/null
pkill -x quickshell 2>/dev/null
pkill -x noctalia 2>/dev/null

# --- Tell the compositor which shell this session wants ---------------------
# execs.lua reads this on hyprland.start and starts the matching shell itself.
export HYPRLAND_SESSION_SHELL=noctalia

# --- Hand the session to the compositor -------------------------------------
# exec replaces this shell with Hyprland so SDDM tracks the real compositor PID.
# The shell is started by execs.lua once the compositor is up.
log "starting Hyprland (shell=noctalia, started by execs.lua)"
if command -v start-hyprland >/dev/null 2>&1; then
    exec start-hyprland
else
    exec Hyprland
fi
