resource "aws_cloudwatch_metric_alarm" "sensor-metric-alarm" {
  alarm_name                = "sensor-metric-alarm"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "2"
  alarm_description         = "Sensor values per drops error rate below threshold"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "m1/m2"
    label       = "Error Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "Sensor Data"
      namespace   = "Ingress PRoject"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"
    }
  }

 metric_query {
    id = "m2"

    metric {
      metric_name = "Sensor Data Drops"
      namespace   = "Ingress PRoject"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"
    }
  }  
}

module "log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 2.0"

  name = "${var.ingress_log_bucket}/access.log"
  retention_in_days = 7

  tags = {
      terraform = "true"
  }
}

resource "aws_cloudwatch_log_metric_filter" "src-ip-err-cnt" {
  name           = "SourceIPErr"
  pattern        = "{ $.sourceIPAddress != ${var.src_ip} }"
  log_group_name = module.log_group.cloudwatch_log_group_name

  metric_transformation {
    name      = "SourceIPErr"
    namespace = "Ingress Project"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ip-counts" {
  alarm_name                = "src-up-err"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "SourceIPErr"
  namespace                 = "Ingress Project"
  period                    = "120"
  statistic                 = "Sum"
  threshold                 = "5"
  alarm_description         = "This metric monitors source ip errors when posting to ingress bucket"
  insufficient_data_actions = []
}