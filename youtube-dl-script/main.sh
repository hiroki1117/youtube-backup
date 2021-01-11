#!/bin/sh

youtube-dl -o "hoge" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 "https://www.youtube.com/watch?v=F0_tR6kZVI4"

aws s3 cp hoge.mp4 s3://youtubedl-bucket/test/
