local vars = require("variables")
local fn   = require("utils.functions")

hl.on("hyprland.start", function()
    -- Keyring and auth
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- Cursors
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- Location provider and night light
    hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
    hl.exec_cmd("sleep 1 && gammastep")

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")



    -- Start the session's shell.
    --
    -- The shell is started HERE, by the compositor, on purpose. The session
    -- scripts (~/hyperland-*.sh) used to start it themselves before the
    -- compositor was up, polling `hyprctl` until Hyprland answered. On a cold
    -- SDDM login that raced the compositor and left the session as plain
    -- Hyprland with no shell.
    --
    -- Running it from hyprland.start removes the race entirely: this hook only
    -- fires once the compositor is up, so a shell started here is always a child
    -- of a live compositor.
    --
    -- The session scripts export HYPRLAND_SESSION_SHELL to say which shell they
    -- want ("caelestia", "noctalia" or "none"). Anything else / unset means no
    -- shell.
    --
    -- NOTE: do NOT kill `qs` after starting caelestia. `caelestia shell -d`
    -- spawns and supervises `qs -c caelestia -n -d`, so killing it takes the
    -- whole session down after ~5 seconds.
    local session_shell = os.getenv("HYPRLAND_SESSION_SHELL")

    if session_shell == "caelestia" then
        hl.exec_cmd("caelestia shell -d")
    elseif session_shell == "noctalia" then
        hl.exec_cmd("noctalia -d")
    end
    -- If no shell was chosen by a session script, show the graphical chooser
    -- so the user can pick one at boot instead of committing at the greeter.
    if not session_shell then
        hl.exec_cmd("python3 " .. os.getenv("HOME") .. "/.config/hypr/shell-chooser.py")
    end
end)

-- Resizer listeners
local function apply_resizer_rules(win)
    local float_center = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.center({ window = win }),
    }
    local pip_actions = fn.move_actions(win) or {}

    -- Bitwarden
    fn.resizer(win, "Bitwarden", 20, 54, float_center, true, "class")                                       -- Native app
    fn.resizer(win, "^Extension: %(Bitwarden Password Manager%) %- Bitwarden", 20, 54, float_center, false) -- Firefox
    fn.resizer(win, "nngceckbapebfimnlniiiahkandclblb", 20, 54, float_center, true, "class")                -- Chromium

    -- Picture in picture
    fn.resizer(win, "Picture[- ]in[- ][Pp]icture", 0, 0, pip_actions, false)
end

hl.on("window.title", apply_resizer_rules)
hl.on("window.open", apply_resizer_rules)
