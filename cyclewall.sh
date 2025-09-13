#!/usr/bin/sh

# check for swww and swww-daemon proc status
/usr/bin/pgrep -x swww >/dev/null && { echo "swww is already running. Effort should not be duplicated."; exit 1; }
/usr/bin/pgrep -x swww-daemon >/dev/null || { echo "swww-daemon not running. Cannot set wallpaper."; exit 1; }

dir="$HOME/Projects/Muur-Papier/"
default_wallpaper=""
set_default_wallpaper=false
reverse=false
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
		--default-wallpaper|-d)
			echo "default $2"
			default_wallpaper="$2"
			set_default_wallpaper=true
			shift 2
			;;
		--reverse|-r)
			reverse=true
			shift
			;;
		--copy|-c)
			copy=true
			shift
			;;
		--help|-h)
			echo "Usage: $0 --wallpaper-dir|-w <wallpaper directory> [--help|-h] [--default-wallpaper|-d <wallpaper>] [--reverse|-r] [--copy|-c]"
			echo
			echo "	--wallpaper-dir     -w | Specify the directory to search for images."
			echo "	--default-wallpaper -d | Specify the default wallpaper to use (must be in wallpaper-dir)."
			echo "	--reverse           -r | Reverse the order of the wallpaper cycling."
			echo "	--copy              -c | Copy the same image across each window."
			echo "	--notify            -n | Send a notification when the wallpaper is changed."
			exit 0
			;;
		*)
			echo "Unknown arg: $1"
			echo "Usage: $0 --wallpaper-dir|-d <wallpaper directory> [--default-wallpaper|-d <wallpaper>] [--reverse|-r] [--copy|-c]"
			exit 1
			;;
	esac
done

if $set_default_wallpaper; then
	default_wallpaper="$(/usr/bin/fd -1atfile "$(/usr/bin/basename "$default_wallpaper")" "$dir")"
	if [[ -n "$default_wallpaper" ]]; then
		if /usr/bin/swww query | grep -vq "$default_wallpaper"; then
			/usr/bin/swww img -t=none "$default_wallpaper"
		else
			echo "Default wallpaper already set."
		fi
		exit 0
	else
		exit 1
	fi
fi

images=($(/usr/bin/fd -at f -e jpg -e gif . "$dir"))
num_images=${#images[@]}
(( num_images == 0 )) && { echo "No images found."; exit 1; }

F=$(/usr/bin/fd 'hyprwall' /tmp --type f)
if [[ $F == "" ]]; then
	F=$(/usr/bin/mktemp /tmp/hyprwall.XXX)
fi

if [[ ! -s $F ]]; then
	echo 0 > "$F"
	INDEX=0
else
	read -r INDEX < "$F"
	if $reverse; then
		INDEX=$(((INDEX + num_images - 1) % num_images))
	else
		INDEX=$(((INDEX + 1) % num_images))
	fi
	echo "$INDEX">"$F"
fi

rand_img() {
	local index=${1:-0}
	local len=${2:-0}
	(( len == 0 )) && { echo "No images found."; exit 1; }
	echo "${images[index % len]}"
}

notif() {
	# 1 = icon 2 = display
	notify-send --urgency=low --expire-time=1000 --icon="$1" "($2) Wallpaper changed successfully"
}

monitors=($(/usr/bin/hyprctl monitors 2>/dev/null | /usr/bin/awk '/Monitor/ {print $2}' | /usr/bin/sort -r))
len=${#monitors[@]}
(( len == 0 )) && { echo "No monitors found."; exit 1; }

if $copy; then
	img="$(rand_img $INDEX $num_images)"
	monitor_string=$(IFS=, ; echo "${monitors[*]}")
	/usr/bin/swww img -t=none --outputs="$monitor_string" "$img" && \
		[ $notify -eq 1 ] && notif "$img" "$monitor_string" &
else
	for ((i = 0; i < len; i++));do
		idx=$((INDEX+i))
		img="$(rand_img $idx $num_images)"
		/usr/bin/swww img -t=none --outputs="${monitors[i]}" "$img" && \
			[ $notify -eq 1 ] && notif "$img" "${monitors[i]}" &
	done
fi

wait
