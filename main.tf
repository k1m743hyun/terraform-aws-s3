resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  force_destroy = true

  tags = merge(
    var.tags,
    {
      "Name": var.bucket_name,
      "Type": "s3"
    }
  )
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id

  acl = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": data.aws_caller_identity.this.arn
          },
          "Action": "s3:ListBucket",
          "Resource": [
            "arn:aws:s3:::${var.bucket_name}"
          ]
        },
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": data.aws_caller_identity.this.arn
          },
          "Action": [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource": [
            "arn:aws:s3:::${var.bucket_name}/*"
          ]
        }
      ]
    }
  )
}