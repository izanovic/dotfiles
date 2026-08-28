#!/bin/bash

# Spawn placeholder
bspc node -i
# Swap placeholder with sticky node
bspc node $(bspc query -N -n .leaf.sticky) -s $(bspc query -N -n .leaf.\!window)
