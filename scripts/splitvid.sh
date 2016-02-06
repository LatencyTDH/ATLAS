#!/bin/bash
#
# Splits the input video into frames.

# Create log file.
sudo mkdir /var/log/compute/
LOG=/var/log/compute/startup_script_log.txt
sudo touch "$LOG"
sudo chmod 666 "$LOG"

FILE="$1"
sudo mkdir "/tmp/atlas"

# Splits the video into individual jpg frames
split_video() {
	echo "$1"
	OUT_PATH="/tmp/atlas/""$(basename $1)"
	OUT_PATH="${OUT_PATH%.mp4}" 
	sudo mkdir "$OUT_PATH"
	sudo mkdir "${OUT_PATH}/frames"
	# Creates one image per second of video
	sudo ffmpeg -i $FILE -f image2 -vf fps=1 "${OUT_PATH}/frames/out-%04d.jpg"
}

# Error logging
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

# Crop video at specified start and ending times
# $1: Start time (Eg. 00:01:30)
# $2: End time 
crop() {
	 ffmpeg -i $FILE -ss $1 -t $2 output.mp4
}

if [ -f "$FILE" ] && [[ "$FILE" == *".mp4" ]]; then
	split_video "$FILE"
else
	err "Inappropriate video file. Unable to split."
fi


