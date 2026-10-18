--[[

    hypr-user.lua -- extra keybinds, ported from KDE Plasma's keymap.kksrc

    Caelestia already ships a complete keymap in ../hypr/variables.lua and
    registers it in ../hypr/keybinds.lua. This file is loaded *after* all of
    that (see ../hyprland.lua, the last require), so everything here is purely
    ADDITIVE: nothing existing is rebound, shadowed or removed.

    Only bindings that do not collide with a Caelestia bind were taken. Where
    KDE's shortcut has a direct Hyprland/Caelestia equivalent it is used; the
    ones with no counterpart (per-application window cycling, "Edit Tiles",
    "Grid View", activity switching, keyboard-layout switching) were left out
    rather than bound to something that behaves differently.

--]]

-- ---------------------------------------------------------------------------
--  KRunner / application launcher
--
--  KDE:    Meta+Space, Alt+Space, Alt+F2  (org.kde.krunner.desktop)
--  Hypr:   Super+Space is free (Caelestia only uses Ctrl+Super+Space for
--           media play/pause), and Alt+F2 is unused entirely.
-- ---------------------------------------------------------------------------
hl.bind("SUPER + Space", hl.dsp.global("caelestia:launcher"))
hl.bind("ALT + F2", hl.dsp.global("caelestia:launcher"))

-- ---------------------------------------------------------------------------
--  Expose / Expose All
--
--  KDE:    Meta+F9 (Expose, current screen), Meta+F10 (ExposeAll)
--           Ctrl+F9 / Ctrl+F10 were the same actions in older keymaps.
--  Hypr:   Caelestia already exposes this on Super+S, but that lives on a
--           modifier Caelestia uses heavily, so F9/F10 are added as the
--           muscle-memory equivalent.
-- ---------------------------------------------------------------------------
hl.bind("SUPER + F9", hl.dsp.exec_cmd("caelestia toggle specialws"))
hl.bind("SUPER + F10", hl.dsp.exec_cmd("caelestia toggle specialws"))

-- ---------------------------------------------------------------------------
--  Previous activity
--
--  KDE:    Meta+Shift+A
--  Hypr:   the workspace you were on before the current one, which is what
--           Hyprland's "-1" workspace selector does.
-- ---------------------------------------------------------------------------
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("hyprctl dispatch workspace -1"))

-- ---------------------------------------------------------------------------
--  System Monitor
--
--  KDE:    Meta+Esc  (org.kde.plasma-systemmonitor.desktop)
--  Hypr:   Caelestia's system monitor special workspace is currently only on
--           Ctrl+Shift+Escape; this adds the KDE chord.
-- ---------------------------------------------------------------------------
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("caelestia toggle sysmon"))

-- ---------------------------------------------------------------------------
--  Kill Window
--
--  KDE:    Meta+Ctrl+Esc
--  Hypr:   killactive force-closes the focused window without a close
--           request, so a hung app can still be cleared. Super+Q is the
--           polite close and is left as Caelestia defined it.
-- ---------------------------------------------------------------------------
hl.bind("SUPER + CTRL + Escape", hl.dsp.exec_cmd("hyprctl dispatch killactive"))


-- ---------------------------------------------------------------------------
--  Terminal launch
--
--  KDE:    Meta+Return              ([kitty.desktop] _launch)
--          Ctrl+Alt+T               ([org.kde.konsole.desktop] _launch)
--
--  Hypr:   Super+T already opened the terminal, but Super+Return is the
--           chord this keymap used and Ctrl+Alt+T is near-universal muscle
--           memory, so both are added. Neither collides with anything
--           Caelestia binds.
--
--  vars.terminal is read rather than hardcoded: hypr-vars.lua overrides it to
--  "kitty", and require() hands back that same already-patched table, so these
--  binds follow the override automatically.
-- ---------------------------------------------------------------------------
do
    local vars = require("variables")
    local term = (vars and vars.terminal) or "kitty"

    hl.bind("SUPER + Return", hl.dsp.exec_cmd(term))
    hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(term))
end
