resource "aws_dynamodb_table" "youtube-backup-table" {
  name           = "YoutubeBackup"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "video_id"
  range_key      = "title"

  attribute {
    name = "video_id"
    type = "S"
  }

  attribute {
    name = "title"
    type = "S"
  }
}