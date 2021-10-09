module "lambda_function_externally_managed_package" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "ingress-handler"
  description   = "Handler function for ingress events"
  handler       = "ingress-handler.lambda_handler"
  runtime       = "python3.8"
  attach_policy = true
  policy = var.robot_policy
  create_package = false

  local_existing_package = "./ingress-handler/ingress-handler.zip"

  environment_variables = {
    SLACK_WEBHOOK_URL = var.slack_webhook
    SLACK_USER = var.slack_user
    SLACK_CHANNEL = var.slack_channel
  }

  tags = {
    Name = "ingress-handler"
    terraform = "true"
  }
}

resource "aws_lambda_permission" "allow-bucket" {
   statement_id = "AllowExecutionFromS3Bucket"
   action = "lambda:InvokeFunction"
   function_name = module.lambda_function_externally_managed_package.lambda_function_arn
   principal = "s3.amazonaws.com"
   source_arn = var.ingress_s3
}

resource "aws_s3_bucket_notification" "notification" {
   bucket = var.ingress_s3_id
   lambda_function {
       lambda_function_arn = module.lambda_function_externally_managed_package.lambda_function_arn
       events = ["s3:ObjectCreated:*"]
   }

   depends_on = [ aws_lambda_permission.allow-bucket ]
}