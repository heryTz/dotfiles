# CLAUDE.md

Guidance for Claude Code working with Hyprland configuration files in `~/.config/hypr/`:

- **hyprland.conf** - Main window manager config
- **hyprlock.conf** - Screen locker
- **hypridle.conf** - Idle daemon
- **hyprpaper.conf** - Wallpaper daemon
- **waybar/** - Status bar

## Commands

**Reload config**: `hyprctl reload` or `Super+Shift+R` (requires reload for most changes, full restart for permissions)

**Keybindings**:
- Focus: `Super+H/J/K/L`
- Swap: `Super+Shift+H/J/K/L`
- Workspace: `Super+[0-9]`

**Troubleshooting**:
- `hyprctl version` - Check version/status
- `journalctl --user -u hyprland -b` - View logs
- Syntax errors appear on reload

## Configuration

**Keyboard**: US+FR layouts, toggle with Alt+Shift

**Display**: eDP-1 @ 1920x1080@60Hz, workspaces 1-3 persistent

**Layout**: Master mode; new windows as "slaves", toggle pseudotile with `Super+P`

**Keybindings**:
- `bind` - normal
- `bindl` - lockscreen
- `bindel` - locked + level (volume/brightness)
- `bindm` - mouse

**Variables**: `$mainMod=SUPER`, `$terminal=alacritty`, `$fileManager=dolphin`, `$menu=rofi -show run`

**Autostart**: waybar, hyprpaper, hypridle (300s lock timeout), hyprpolkitagent

**Decor**: Master layout, 5px inner/15px outer gaps, 8px rounding, blur enabled, cyan→green border gradient (45°), animations disabled

**Lock screen**: Inter font, 3-pass blur, layout indicator, 300s idle timeout

## Common Edits

**Add keybinding**: `bind = $mainMod SHIFT, [KEY], [ACTION], [PARAMS]` (e.g., `bind = $mainMod, Q, exec, firefox`)

**Add workspace**: `workspace = 4, monitor:eDP-1, persistent:true`

**Window rule**:
```
windowrule {
    name = rule-name
    match:class = app-class
    [property] = value
}
```

Existing rules: suppress maximize, fix XWayland drag, hyprland-run handling

## Resources

- [Hyprland Wiki](https://wiki.hypr.land/)
- [Config Guide](https://wiki.hypr.land/Configuring/)
- [Keybindings](https://wiki.hypr.land/Configuring/Binds/)
- [Window Rules](https://wiki.hypr.land/Configuring/Window-Rules/)
