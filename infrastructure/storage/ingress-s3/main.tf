data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:PutObject"
    ]

    resources = [
        "arn:aws:s3:::${var.ingress_s3_bucket}",
        "arn:aws:s3:::${var.ingress_s3_bucket}/*"
    ]

    condition {
      test = "IpAddress"
      variable = "aws:SourceIp"
      values = [var.src_ip]
    }

    principals {
      type = "*"
      identifiers = ["*"]
    }
  }
}

module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.ingress_s3_bucket}-logs"
  acl    = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true
}

module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.9.0"

  bucket = var.ingress_s3_bucket
  force_destroy = true
  attach_policy = true
  acl = "private"

  versioning = { 
    enabled = false
  }

  logging = {
    target_bucket = module.s3_bucket_for_logs.s3_bucket_id
    target_prefix = "log/"
  }

  tags =  {
    Name = "ingress-bkt"
    terraform = "true"
  }

  policy = data.aws_iam_policy_document.bucket_policy.json
}
