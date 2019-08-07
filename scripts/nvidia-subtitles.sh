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
mediainfo --Inform="Video;codec_name=%Codec%" "$1" >> "$1".txt
source "$1".txt
if [ $codec_name = "AVC" ] ; then
ffmpeg -i "$1" -c:v copy -ac 2 -c:a libfdk_aac -b:a 192k "$map/$mp4"
else ccextractor "$1" -o "$map/$srt"
fi
if [ $codec_name = "MPEG-2V" ] ; then
if [ -f "$map/$srt" ] && [[ $(find "$map/$srt" -type f -size +200c 2>/dev/null) ]] ; then
ffmpeg -hwaccel cuvid -c:v mpeg2_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -i "$map/$srt" -c:v hevc_nvenc -preset:v hp -level:v 5.0 -rc:v vbr_hq -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 192k -c:s mov_text "$map/$mp4"
else echo "*** CCextractor couldn't find Closed Captions. No Subtitles will be added...***"
ffmpeg -hwaccel cuvid -c:v mpeg2_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -c:v hevc_nvenc -preset:v hp -level:v 5.0 -rc:v vbr_hq -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 192k "$map/$mp4"
fi
fi
if [ $codec_name != "AVC" ] && [ $codec_name != "MPEG-2V" ] ; then
if [ -f "$map/$srt" ] && [[ $(find "$map/$srt" -type f -size +200c 2>/dev/null) ]] ; then
ffmpeg -hwaccel nvdec -i "$1" -i "$map/$srt" -c:v hevc_nvenc -preset:v hp -level:v 5.0 -rc:v vbr_hq -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 192k -c:s mov_text "$map/$mp4"
else echo "*** CCextractor couldn't find Closed Captions. No Subtitles will be added...***"
ffmpeg -hwaccel nvdec -i "$1" -c:v hevc_nvenc -preset:v hp -level:v 5.0 -rc:v vbr_hq -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 192k "$map/$mp4"
fi
fi
if [ -f "$map/$srt" ] ; then
rm "$map/$srt"
fi
rm "$1".txt
#SEDIF [ -f "$map/$mp4" ] && [ -s "$map/$mp4" ] ; then
