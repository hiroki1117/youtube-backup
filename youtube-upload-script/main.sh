#!/bin/sh
set -eu

echo $S3PATH
echo $VIDEO_TITLE
echo $PRIVACY_STATUS

# S3のパスから動画ファイル名を取得
array=( `echo $S3PATH | tr -s '/' ' '`)
last_index=`expr ${#array[@]} - 1`
FILENAME=${array[${last_index}]}
echo $FILENAME

# S3から動画ダウンロード
aws s3 cp "${S3PATH}" "${FILENAME}"

# Youtubeにアップロード
python upload_video.py --file="${FILENAME}" \
                       --title="${VIDEO_TITLE}" \
                       --description="" \
                       --keywords="" \
                       --category="22" \
                       --privacyStatus="${PRIVACY_STATUS}"
