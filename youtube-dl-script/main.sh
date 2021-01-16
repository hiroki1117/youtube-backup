#!/bin/sh

filename=$(youtube-dl --get-filename $URL)

echo $URL
echo $filename

youtube-dl -o "$filename" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 "$URL"

#webmとかでファイル名が異なる場合はmp4に修正
if [ ! -f $filename ]; then
  filename=${filename}.mp4
fi

aws s3 cp "${filename}" s3://youtubedl-bucket/test/
