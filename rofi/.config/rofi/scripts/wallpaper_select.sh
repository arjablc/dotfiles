#!/bin/bash

WALL_DIR="$HOME/Downloads/wallpapers"
ROFI_CONFIG="$HOME/.config/rofi/wallpaper-config.rasi"

mapfile -t WALLPAPERS < <(find "$WALL_DIR" -type f \( -iname '*.jpeg' -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.webp' \) | sort)

[[ ${#WALLPAPERS[@]} -eq 0 ]] && {
    notify-send -t 1000 "No wallpapers found in $WALL_DIR"
    exit 1
}

SELECTED=$(for wallpaper in "${WALLPAPERS[@]}"; do
    basename_file=$(basename "$wallpaper")
    clean_name="${basename_file%.*}"
    echo -en "$clean_name\0icon\x1f$wallpaper\n"
done | rofi -dmenu -show-icons -config "$ROFI_CONFIG" -p "Select Wallpaper")

[[ -z "$SELECTED" ]] && exit 0

for wallpaper in "${WALLPAPERS[@]}"; do
    basename_file=$(basename "$wallpaper")
    clean_name="${basename_file%.*}"
    if [[ "$clean_name" == "$SELECTED" ]]; then
        swww img "$wallpaper"
				wallust run "$wallpaper"
        notify-send -t 1000 "Wallpaper Changed" "$basename_file"
        break
    fi
done
