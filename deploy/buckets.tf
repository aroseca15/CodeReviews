## Zoom webhook bucket

resource "aws_s3_bucket" "telepsycrx-zoom" {
  bucket = "telepsycrx-zoom"

  tags = {
    Name        = "telepsycrx-zoom"
  }
}

resource "aws_s3_bucket_acl" "telepsycrx-zoom" {
  bucket = aws_s3_bucket.telepsycrx-zoom.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "telepsycrx-zoom" {
  bucket = aws_s3_bucket.telepsycrx-zoom.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

## Media bucket
resource "aws_s3_bucket" "telepsycrx-media" {
  bucket = "telepsycrx-media"

  tags = {
    Name        = "telepsycrx-media"
  }
}

resource "aws_s3_bucket_acl" "telepsycrx-media" {
  bucket = aws_s3_bucket.telepsycrx-media.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "telepsycrx-media" {
  bucket = aws_s3_bucket.telepsycrx-media.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}
