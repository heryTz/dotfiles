#!/bin/bash
floating=$(hyprctl activewindow -j | jq -r '.floating')
if [ "$floating" = "true" ]; then
  hyprctl dispatch togglefloating
else
  hyprctl dispatch setfloating
  hyprctl dispatch resizeactive exact 800 500
  hyprctl dispatch centerwindow
fi
