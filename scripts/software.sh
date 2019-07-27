#!/bin/bash
date=$(date +"%d-%m-%Y-%H%M")
LogFile=/config/log/postProcess.$date.log
IFS=$(echo -en "\n\b")
mkv="$(basename $1)"
map="$(dirname $1)"
mp4="${mkv%.*}.mp4"
mp4="$(basename $mp4)"
srt="${mkv%.*}.srt"
srt="$(basename $srt)"
exec 3>&1 1>>${LogFile} 2>&1
ffmpeg -i "$1" -c:v libx265 -brand mp42 -preset medium -x265-params crf=22 -ac 2 -c:a aac -b:a 192k -ac 2 -c:a aac -b:a 192k "$map/$mp4"
#SEDIF [ -f "$map/$mp4" ] && [ -s "$map/$mp4" ]; then
