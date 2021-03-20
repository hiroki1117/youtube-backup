resource "aws_dynamodb_table" "youtube-backup-table" {
  name           = "YoutubeBackup"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "video_id"

  attribute {
    name = "video_id"
    type = "S"
  }
}