output "robot_role" {
  value = aws_iam_role.ingress_prj_robot.arn
}
output "robot_policy" {
  value = aws_iam_policy.ingress_prj_robot.arn
}