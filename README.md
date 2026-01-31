> [!Warning]
> このプロジェクトのメンテは終了しました  
> 以降Terraformの操作を行わないこと


# Youtube Backup

URLからS3に動画データをバックアップする
![](https://i.gyazo.com/9b7eea43c7ee2e53b82c8fcd7876f135.png)
## 構成
[Swagger UIで確認](https://hiroki1117.github.io/youtube-backup/dist/index.html)
|  Lambda  |  役割  |
| ---- | ---- |
|  submit-job-lambda  |  動画ダウンロード処理をBatchに登録  |
|  complete-video-upload  |  動画ダウンロードが完了してS3に置かれたらDynamoに完了ステータスを記録  |
|  delete-video-lambda  |  動画を削除  |
|  scrapbox-backup-lambda  |  Scrapboxの自分のプロジェクトに記載されたYoutube動画を自動でバックアップする  |
|  video-info-lambda  |  バックアップした動画情報をvideo_idから取得  |
|  video-list-lambda  |  バックアップした動画情報の一覧を取得  |
|  presigned-s3url-lambda  |  S3にアクセスするための一時的なURLの発行  |


