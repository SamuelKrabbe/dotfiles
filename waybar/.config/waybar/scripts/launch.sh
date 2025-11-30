#!/usr/bin/env bash

killall waybar
waybar -c $HOME/.config/waybar/config.jsonc &
