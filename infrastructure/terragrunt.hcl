terraform {
  before_hook "checkov" {
    commands = ["plan"]
    execute = [
      "checkov",
      "-d",
      ".",
      "-d",
      ".terraform",
      "--quiet",
      "--framework",
      "terraform"
    ]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "ingress-prj.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = get_env("INGRESS_PRJ_STATE_BKT")
    acl = "private"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "ingress-prj-lock-table"
  }
}

## we're assuming the current exposure of credentials
## through environment variables
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "us-west-2"
}
EOF
}