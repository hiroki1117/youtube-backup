#!/bin/sh


echo $URL
echo $FILENAME

youtube-dl -o "$FILENAME" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 "$URL"

aws s3 cp "${FILENAME}" "${S3PATH}"
