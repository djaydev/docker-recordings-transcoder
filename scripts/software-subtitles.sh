#!/bin/bash
date=$(date +"%d-%m-%Y-%H%M")
LogFile=/config/log/postProcess.$date.log
IFS=$(echo -en "\n\b")
export LD_LIBRARY_PATH=/usr/local/lib
mkv="$(basename $1)"
map="$(dirname $1)"
mp4="${mkv%.*}.mp4"
mp4="$(basename $mp4)"
srt="${mkv%.*}.srt"
srt="$(basename $srt)"
exec 3>&1 1>>${LogFile} 2>&1
ccextractor "$1" -o "$map/$srt"
if [ -f "$map/$srt" ] && [[ $(find "$map/$srt" -type f -size +200c 2>/dev/null) ]] ; then
ffmpeg -i "$1" -i "$map/$srt" -c:v libx265 -brand mp42 -preset medium -x265-params crf=22 -ac 2 -c:a libfdk_aac -b:a 192k -c:s mov_text "$map/$mp4"
else echo "*** CCextractor couldn't find Closed Captions. No Subtitles will be added...***"
ffmpeg -i "$1" -c:v libx265 -brand mp42 -preset medium -x265-params crf=22 -ac 2 -c:a libfdk_aac -b:a 192k "$map/$mp4"
fi
#SEDIF
