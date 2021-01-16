#!/bin/sh

filename=$(youtube-dl --get-filename $URL)

echo $URL
echo $filename

youtube-dl -o "$filename" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 "$URL"

aws s3 cp "${filename}" s3://youtubedl-bucket/test/
