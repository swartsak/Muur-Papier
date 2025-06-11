#!/usr/bin/env sh

# check for swww and swww-daemon proc status
/usr/bin/pgrep -x swww >/dev/null && { echo "swww is already running. Effort should not be duplicated."; exit 1; }
/usr/bin/pgrep -x swww-daemon >/dev/null || { echo "swww-daemon not running. Cannot set wallpaper."; exit 1; }
monitors=($(/usr/bin/hyprctl monitors 2>/dev/null | /usr/bin/awk '/Monitor/ {print $2}' | /usr/bin/sort -r))
len=${#monitors[@]}
(( len == 0 )) && { echo "No monitors found."; exit 1; }

dir="~/Projects/Muur-Papier/"
copy=false

while [[ $# -gt 0 ]]; do 
	case "$1" in
		--wallpaper-dir|-w)
			dir="$2"
			shift 2
			;;
		--copy|-c)
			copy=true
			shift
			;;
		--help|-h)
			echo "Usage: $0 --wallpaper-dir|-w <wallpaper directory> [--copy|-c] [--help|-h]"
			echo
			echo "	--wallpaper-dir     -w | Specify the directory to search for images."
			echo "	--copy              -c | Copy the same image across each window. By default you must select $len images."
			echo "	--help              -h | Print this help message."
			exit 0
			;;
		*)
			echo "Unknown arg: $1"
			echo "Usage: $0 --wallpaper-dir|-w <wallpaper directory> [--copy|-c]"
			exit 1
			;;
	esac
done

images="$(/usr/bin/fd -at f -e png -e jpg -e jpeg -e gif . "$dir")"

if $copy; then
	img=$(echo "$images" | ~/.config/hypr/wofi.sh --dmenu)
	for ((i = 0; i < len; i++)); do
		/usr/bin/swww img -t=none --outputs="${monitors[i]}" "$img" &
	done
else
	for ((i = 0; i < len; i++)); do
		img=$(echo "$images" | ~/.config/hypr/wofi.sh --dmenu --prompt="For monitor ${monitors[i]}")
		/usr/bin/swww img -t=none --outputs="${monitors[i]}" "$img" &
	done
fi

wait
