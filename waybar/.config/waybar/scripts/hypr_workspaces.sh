#!/bin/bash

# A bash script to changet he hyprland workspaces based on the current workspace and then scroll to a new one.
#
#
#
#TODO: Can we add a lock file approach for debouncing requests?
#Tooo Lazy

if [[ "$1" == "up" ]]; then
	hyprctl dispatch workspace e+1
	sleep 10
	echo "going r+1 workspace"
elif [[ "$1" == "down" ]]; then
	hyprctl dispatch workspace e-1
	sleep 10
	echo "going r+1 workspace"
fi


	



