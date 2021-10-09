include "root" {
    path = find_in_parent_folders()
}

dependency "policy" {
  config_path = "../../rbac"
}

dependency "ingress" {
  config_path = "../../storage/ingress-s3"
}

inputs = {
  robot_policy = dependency.policy.outputs.robot_policy
  ingress_s3 = dependency.ingress.outputs.ingress_bucket_arn
  ingress_s3_id = dependency.ingress.outputs.ingress_bucket_id
}