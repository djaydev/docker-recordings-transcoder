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
xml="${mkv%.*}.xml"
xml="$(basename $xml)"
d="${mkv%.*}.d"
d="$(basename $d)"
exec 3>&1 1>>${LogFile} 2>&1
mediainfo --Inform="Video;codec_name=%Codec%" "$1" >> "$1".txt
source "$1".txt
if [ $codec_name = "AVC" ] ; then
ffmpeg -i "$1" -c:v copy -ac 2 -c:a libfdk_aac -b:a 192k "$map/$mp4"
else ccextractor "$1" -o "$map/$srt"
fi
if [ $codec_name != "AVC" ] ; then
if [ -f "$map/$srt" ] && [[ $(find "$map/$srt" -type f -size +500c 2>/dev/null) ]] ; then
ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i "$1" -i "$map/$srt" -vf 'format=nv12|vaapi,hwupload,deinterlace_vaapi' -c:v hevc_vaapi -brand mp42 -ac 2 -c:a libfdk_aac -b:a 192k -c:s mov_text "$map/$mp4"
else echo "*** CCextractor couldn't find Closed Captions. No Subtitles will be added...***"
ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i "$1" -vf 'format=nv12|vaapi,hwupload,deinterlace_vaapi' -c:v hevc_vaapi -brand mp42 -ac 2 -c:a libfdk_aac -b:a 192k "$map/$mp4"
fi
fi
if [ -f "$map/$srt" ] ; then
rm "$map/$srt"
fi
rm "$1".txt
#SEDIF
