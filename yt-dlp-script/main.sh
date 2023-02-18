#!/bin/sh
set -eux

echo $URL
echo $FILENAME
echo ${S3PATH}


# mp4でダウンロードが失敗したらマージでダウンロードする
#yt-dlp --recode-video mp4 -o "$FILENAME" "$URL"
yt-dlp -o "$FILENAME.%(ext)s" "$URL"

FULLFILENAME=`find $FILENAME.*`

# 動画をS3にアップロード
aws s3 cp "${FULLFILENAME}" "${S3PATH}"
