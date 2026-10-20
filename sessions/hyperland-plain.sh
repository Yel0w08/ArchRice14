#!/bin/sh
# Plain Hyprland session entry point -- no shell (no noctalia, no caelestia).
#
# Used by /usr/share/wayland-sessions/hyperland-plain.desktop (SDDM), and can
# also be run by hand from a TTY.
#
# Unlike the noctalia and caelestia sessions, this one deliberately starts no
# desktop shell. The shell autostart in ~/.config/hypr/hyprland/execs.lua is
# disabled, so this session comes up as a bare compositor.

log() {
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$HOME/.cache/hyperland-plain.log"
}

# Kill any leftover shell so none of them bleed into this session. `qs` is a
# symlink to `quickshell`, so match both names.
kill_shells() {
    pkill -x qs 2>/dev/null
    pkill -x quickshell 2>/dev/null
    pkill -x noctalia 2>/dev/null
}

# --- Re-run inside an existing session --------------------------------------
# Nothing to start, so just report and leave the compositor alone.
if hyprctl version >/dev/null 2>&1; then
    log "Hyprland already running, plain session does nothing"
    exit 0
fi

# --- Clean slate before Hyprland starts -------------------------------------
kill_shells

# --- Tell the compositor which shell this session wants ---------------------
# Explicitly "none" so execs.lua starts no shell here, even if a stale value
# leaked into the environment. Plain Hyprland means exactly that.
export HYPRLAND_SESSION_SHELL=none

# --- Hand the session to the compositor -------------------------------------
log "starting Hyprland (shell=none)"
if command -v start-hyprland >/dev/null 2>&1; then
    exec start-hyprland
else
    exec Hyprland
fi
