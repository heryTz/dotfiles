#!/bin/bash
floating=$(hyprctl activewindow -j | jq -r '.floating')
if [ "$floating" = "true" ]; then
  hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })'
else
  hyprctl dispatch 'hl.dsp.window.float({ action = "on" })'
  hyprctl dispatch 'hl.dsp.window.resize({ x = 800, y = 500 })'
  hyprctl dispatch 'hl.dsp.window.center()'
fi
