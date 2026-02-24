# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles at `~/.config/` tracked via git. Main components: Hyprland WM (`hypr/`), Waybar (`waybar/`), Neovim (`nvim/`), Alacritty (`alacritty/`), Mako (`mako/`), Rofi (`rofi/`).

## Applying Changes

- **Hyprland**: `hyprctl reload`
- **Waybar**: `killall waybar && waybar &`
- **Mako**: `makoctl reload`
- **Nvim plugins**: `:Lazy sync`
- **Alacritty**: live reload (no command needed)

## Neovim (`nvim/`)

Uses lazy.nvim. Entry point: `init.lua`. Plugins in `lua/plugins/` (one file each). LSP configs in `lsp/`. Custom local plugins in `lua/custom-plugins/`.

- **LSPs**: lua_ls, tailwindcss, eslint, cssls, gopls, jsonls, biome, TypeScript (custom)
- **Formatting**: conform.nvim, format-on-save — prettierd (JS/TS/Vue), stylua (Lua), gofmt (Go)
- **Completion**: blink.cmp
- **Theme**: Tokyo Night Storm

## Hyprland (`hypr/`)

See `hypr/CLAUDE.md` for full details. `$mainMod = SUPER`, display: eDP-1 @ 1920×1080.
