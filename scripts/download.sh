#!/bin/bash
#
# Downloads a Youtube video between two specified times.

URL=$1
OUT_FILE=$2
START=$3 # Start time of video
END=$4   # End time


# Crop video at specified start and ending times
# $1: Start time (Eg. 00:01:30)
# $2: End time 
crop() {
	echo "Cropping ${OUT_FILE} from $1 to $2"
	ffmpeg -i "$OUT_FILE" -ss "$1" -t "$2" output.mp4
	sudo mv output.mp4 ${OUT_FILE}
}

# Tries to get the first matching with quality 720p
sudo youtube-dl -F ${URL} | grep 'mp4' | grep 1280x720 | cut -f 1 -d ' ' | head -n 1 | xargs youtube-dl ${URL} -o "${OUT_FILE}" -f 
crop "${START}" "${END}"
