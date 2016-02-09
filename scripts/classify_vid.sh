#!/bin/bash
#
# Splits the input video into frames.

# Create log file.
sudo mkdir /var/log/compute/
LOG=/var/log/compute/startup_script_log.txt
sudo touch "$LOG"
sudo chmod 666 "$LOG"

get_abspath() {
	ORIG=$(pwd)
	cd $(dirname "$1")
	echo $(pwd)/$(basename "$1")
	cd "${ORIG}"
}

FILE="$1"
NUM_SAMPLES=9 # Number of images to sample from the video
VID_LENGTH=$(ffprobe -i $FILE -show_format | grep duration)
VID_LENGTH=${VID_LENGTH/duration=/""}
FPS=$(bc -l <<< $NUM_SAMPLES/$VID_LENGTH)
THRESHOLD=0.45 # Sensitivity of output classification labels

sudo mkdir "/tmp/atlas"

OUT=""
# Splits the video into individual jpg frames
split_video() {
	echo "$1"
	OUT_PATH="/tmp/atlas/""$(basename $1)"
	OUT_PATH="${OUT_PATH%.mp4}" 
	OUT=$OUT_PATH
	sudo mkdir "$OUT_PATH"
	sudo mkdir "${OUT_PATH}/frames"
	# Creates one image per second of video
	sudo ffmpeg -i $FILE -f image2 -vf fps=$FPS "${OUT_PATH}/frames/out-%04d.jpg"
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

echo "Classifying images in ${OUT}/frames" >> $LOG

VID_NAME=$(basename "${FILE%.mp4}")
get_abspath "${FILE}" > "${OUT}/${VID_NAME}.txt"
python classify_image.py --directory "${OUT}/frames" >> "${OUT}/${VID_NAME}.txt"
python aggregation.py "${OUT}/${VID_NAME}.txt" "${THRESHOLD}" > "${OUT}/tags.json"
