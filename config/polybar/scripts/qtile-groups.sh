#!/bin/bash
# Get current active group from Qtile using qtile cmd-obj

current_group=$(qtile cmd-obj -o root -f get_groups | jq -r '.[] | select(.screen == 0).name')

# Loop 1 through 9
for (( g = 1; g <= 9; g++ )); do
  if [[ "$g" == "$current_group" ]]; then
    printf '● '
  else
    printf '○ '
  fi
done

echo
