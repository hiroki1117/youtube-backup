resource "aws_dynamodb_table" "youtube-backup-table" {
  name         = "YoutubeBackup"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "video_id"

  attribute {
    name = "video_id"
    type = "S"
  }

  attribute {
    name = "upload_status"
    type = "S"
  }

  attribute {
    name = "backupdate"
    type = "S"
  }

  global_secondary_index {
    name            = "upload_status-backupdate-index"
    hash_key        = "upload_status"
    range_key       = "backupdate"
    projection_type = "ALL"
    read_capacity   = 0
    write_capacity  = 0
  }
}
