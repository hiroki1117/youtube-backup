#!/bin/sh
set -u

echo $URL
echo $FILENAME
echo ${S3PATH}


# mp4でダウンロードが失敗したらマージでダウンロードする
# youtube-dl -o "$FILENAME" -f "best[ext=mp4]" "$URL" || youtube-dl -o "$FILENAME" -f "best[ext=mp4]/best" --merge-output-format mp4 "$URL"
yt-dlp --recode-video mp4 -o "$FILENAME" "$URL"

# 動画をS3にアップロード
aws s3 cp "${FILENAME}" "${S3PATH}"
