#!/bin/bash

# set up the two monitors for bspwm
# NOTE This is a simplistic approach because I already know the settings I
# want to apply.
my_laptop_external_monitor=$(xrandr --query | grep 'HDMI1')
if [[ $my_laptop_external_monitor = *connected* ]]; then
  xrandr --output eDP1 --mode 1920x1080 --pos 0x0 --rotate normal --primary --output HDMI1 --mode 2560x1440 --pos 1920x0 --rotate normal 
fi
