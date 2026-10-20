#!/bin/sh
# Lock the session using whichever shell is actually running.
#
# Why this exists: Hyprland keybinds are static, but this machine has two
# switchable shells (Caelestia and Noctalia) and each has its OWN lock screen.
# Binding both on the same key means both fire and race; binding only one means
# the key does nothing in the other session. So SUPER + L calls this, and it
# picks the right locker for the session that is currently up.
#
# Called from ~/.config/hypr/hyprland/keybinds.lua (vars.kbLockNoctalia).
#
# NOTE: this is unrelated to hyprlock, which is on SUPER + SHIFT + L and works
# in either session.

set -u

# --- Detect the running shell -------------------------------------------
# Caelestia is a Quickshell instance whose config is named "caelestia", so it
# shows up as `qs -c caelestia`. Noctalia is a plain `noctalia` process.
#
# Noctalia is checked first: if both were somehow up, Noctalia is the shell
# that owns the panels there, so its lock is the one the user expects.
if pgrep -x noctalia >/dev/null 2>&1; then
    exec noctalia msg session lock
fi

# Caelestia's lock is exposed as an IPC target named "lock" inside its
# Quickshell instance (see .../caelestia/modules/lock/Lock.qml). The shell
# scripts wrap this as `caelestia shell`, but calling qs directly avoids
# depending on the Python wrapper being on PATH.
if pgrep -f 'qs -c caelestia' >/dev/null 2>&1; then
    exec qs -c caelestia ipc call lock lock
fi

# --- Fallback ------------------------------------------------------------
# Neither shell detected. Rather than do nothing and leave the session
# unlocked, fall back to hyprlock so SUPER + L always locks something.
#
# hyprlock exits without locking if its config is missing, so check first.
if [ -r "$HOME/.config/hypr/hyprlock.conf" ] && command -v hyprlock >/dev/null 2>&1; then
    exec hyprlock
fi

notify-send -u critical "Lock failed" "No shell lock available and hyprlock is not usable."
exit 1
