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

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_backup_plan" "plan" {
  name = "YoutubeBackupDynamoDBBackupPlan"
  rule {
    rule_name         = "YoutubeBackupRule"
    target_vault_name = aws_backup_vault.vault.name
    schedule          = "cron(0 12 * * ? *)"
    lifecycle {
      delete_after = 35
    }
  }
}

resource "aws_backup_vault" "vault" {
  name = "YoutubeBackupVault"
}

resource "aws_backup_selection" "selection" {
  iam_role_arn = data.aws_iam_role.BackupRole.arn
  name         = "YoutubeBackupSelection"
  plan_id      = aws_backup_plan.plan.id
  resources = [
    aws_dynamodb_table.youtube-backup-table.arn
  ]
}

data "aws_iam_role" "BackupRole" {
  name = "AWSBackupDefaultServiceRole"
}