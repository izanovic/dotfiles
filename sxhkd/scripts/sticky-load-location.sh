#!/bin/bash
# Move sticky node inside placeholder
bspc node $(bspc query -N -n .leaf.sticky) -n $(bspc query -N -n .leaf.\!window)
