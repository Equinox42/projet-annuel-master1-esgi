# # Backup bucket
# resource "aws_s3_bucket" "backup_bucket" {
#   bucket = "${var.name}-backup-bucket"
# }

# # Backup retention period on bucket
# resource "aws_s3_bucket_lifecycle_configuration" "backup_lifecycle" {
#   bucket = aws_s3_bucket.backup_bucket.id

#   rule {
#     id     = "expire-old-backups"
#     status = "Enabled"

#     filter {
#       prefix = ""
#     }

#     expiration {
#       days = var.expiration_days
#     }
#   }
# }

# # Bucket versionning activation
# resource "aws_s3_bucket_versioning" "versioning" {
#   bucket = aws_s3_bucket.backup_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }