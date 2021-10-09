
output "ingress_bucket_arn" {
  value = module.s3-bucket.s3_bucket_arn
}

output "ingress_bucket_id" {
  value = module.s3-bucket.s3_bucket_id
}