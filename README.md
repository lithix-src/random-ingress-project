# Overview

We provide an interface for the management of infrastructure for event based consumption of file based ingress. 

## Services provided
- [Initial Deployment](#Initial-Depolyment)
- [Requirements](#Requirements)
- [Outputs](#Outputs)

# Initial Deployment 

1. Build application container `make build`

2. Export configuration variables
```
export AWS_ACCESS_KEY_ID=ABC123
export AWS_SECRET_ACCESS_KEY=ABC123
export AWS_ACCT_NUMBER=1234567

## bucket ingress firewall
export TF_VAR_src_ip=1.2.3.4

## automation values
export INGRESS_PRJ_STATE_BKT="random-ingress-prj-state-bkt"
export TF_VAR_slack_webhook=ingress-app
export TF_VAR_slack_user=ingress-app
export TF_VAR_slack_channel="#random-bots"
```

3. Run `make app` to deploy full application and supporting environment

## Requirements
- make
- docker
- aws cli
- a slack application with webhook

## Outputs

- IAM roles and resources
- AWS S3 buckets for application and infrastructure with access logging
- Configured access to ingress bucket via src ip address
- Lambda slackbot alert parser
- Custom AWS CloudWatch metrics

# Application

The application mimics the concept of a file ingress parser. The parser simply assumes it can read an incoming file, sum the first row of a csv. 

The summed value is then output to a slack channel.

Errors and alerts are output to a configured channel.