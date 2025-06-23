#!/usr/bin/env sh

# check for swww and swww-daemon proc status
/usr/bin/pgrep -x swww >/dev/null && { echo "swww is already running. Effort should not be duplicated."; exit 1; }
/usr/bin/pgrep -x swww-daemon >/dev/null || { echo "swww-daemon not running. Cannot set wallpaper."; exit 1; }
monitors=($(/usr/bin/hyprctl monitors 2>/dev/null | /usr/bin/awk '/Monitor/ {print $2}' | /usr/bin/sort -r))
len=${#monitors[@]}
(( len == 0 )) && { echo "No monitors found."; exit 1; }

dir="$HOME/Projects/Muur-Papier/"
copy=false
notify=0

while [[ $# -gt 0 ]]; do 
	case "$1" in
		--wallpaper-dir|-w)
			dir="$2"
			shift 2
			;;
		--notify|-n)
			notify=1
			shift 1
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

notif() {
	# 1 = icon 2 = display
	notify-send --urgency=low --expire-time=1000 --icon="$1" "($2) Wallpaper changed successfully"
}

images="$(/usr/bin/fd -at f -e jpg -e gif . "$dir")"

if $copy; then
	img=$(echo "$images" | ~/.config/hypr/wofi.sh --dmenu)
	if [ -z "$img" ]; then
		exit 1
	fi
	echo "Using: $img"
	monitor_string=$(IFS=, ; echo "${monitors[*]}")
	/usr/bin/swww img -t=none --outputs="$monitor_string" "$img" && \
		[ $notify -eq 1 ] && notif "$img" "$monitor_string" &
else
	for ((i = 0; i < len; i++)); do
		img=$(echo "$images" | ~/.config/hypr/wofi.sh --dmenu --prompt="For monitor ${monitors[i]}")
		if [ -z "$img" ]; then
			exit 1
		fi
		echo "Using: $img"
		/usr/bin/swww img -t=none --outputs="${monitors[i]}" "$img" && \
			[ $notify -eq 1 ] && notif "$img" "${monitors[i]}" &
	done
fi

wait
