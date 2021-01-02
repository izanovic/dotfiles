#bspc add variable to node bspwm!/bin/bash
s=$1
d=$2
list=("1" "3")

if [ -n "$(bspc query -N -n .leaf.sticky)" ]; then
  # # Spawn placeholder
  # bspc node -i;
  # # Swap p|| true laceholder with sticky node
  # bspc node $(bspc query -N -n .leaf.sticky) -s $(bspc query -N -n .leaf.\!window);
  bspc desktop -f "^"$d
  # bspc node $(bspc query -N -n .leaf.sticky) -n $(bspc query -N -n .leaf.\!window);

  
  if [[ " ${list[@]} " =~ " $d " ]]; then
  # if [ "$d" == "3" ]; then
    bspc node $(bspc query -N -n .leaf.sticky) -g hidden=off
  else
    bspc node $(bspc query -N -n .leaf.sticky) -g hidden=on
  fi
else
  if [ $1 == 0 ]; then
    bspc desktop -f $(bspc query -M -m .focused):"^"$d
  else
    bspc desktop -f $(bspc query -M -m .!focused):"^"$d
  fi
fi
