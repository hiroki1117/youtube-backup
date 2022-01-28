# Youtube Backup

URLからS3に動画データをバックアップする
![](https://i.gyazo.com/9b7eea43c7ee2e53b82c8fcd7876f135.png)
## 構成
### submit-job-lambda
動画ダウンロード処理をBatchに登録

### complete-video-upload
動画ダウンロードが完了してS3に置かれたらDynamoに完了ステータスを記録

### delete-video-lambda
動画を削除

