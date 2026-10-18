-- ============================================================================
--  Caelestia user overrides
--
--  Anything returned here overrides the matching key in
--  ~/.config/hypr/variables.lua. This is the supported place to change
--  things: `caelestia update` will not clobber it.
--
--  Format is a Lua table: { key = value, ... }
-- ============================================================================

return {
    -- kitty is now the default terminal (kitty.conf already sets `shell zsh`)
    terminal = "kitty",

    -- Cursor
    --
    -- The dotfiles default to "sweet-cursors", but that theme is not installed
    -- on this machine (pacman: sweet-cursors not found), so Hyprland was
    -- falling back to an unthemed cursor.
    --
    -- breeze_cursors is the KDE Breeze set that ships with breeze-cursors: 115
    -- cursor files, fully animated, and the sharpest of the installed options.
    -- The name must match the icon theme directory, which is why this is
    -- "breeze_cursors" and not "Breeze".
    --
    -- For the upstream Hyprland default instead (Bibata-Modern-Classic):
    --   sudo pacman -S hypr-cursor
    --   then set cursorTheme = "Bibata-Modern-Classic" here
    cursorTheme = "breeze_cursors",
    cursorSize  = 24,
}
