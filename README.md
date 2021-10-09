# Overview

We provide an interface for the management of infrastructure for event based consumption of file based ingress. 

## Services provided
1. [Initial Deployment](#Initial-Depolyment)
2. [Requirements](#Requirements)
3. [Outputs](#Outputs)
4. [Application](#Application)
5. [Reasoning](#Reasoning)
6. [What I Would Fix](#What-I-Would-Fix)

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
export TF_VAR_ingress_s3_bucket=scratch-ingress-prj
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
- Assumed ingress file csv sensor data handling
- Custom AWS CloudWatch metrics and alarms

# Application

The application mimics the concept of a file ingress parser. The parser simply assumes it can read an incoming file, sum the first row of a csv. 

The summed value is then output to a slack channel and used for custom CloudWatch metrics. Metrics data is then used for custom metric queries and alerting. Logs are also parsed as custom metrics and used for alert generation. Parse data is output to custom slack channel, as well as parsing errors.

# Reasoning

## make

`make` is just about every where and easy to learn as a simple **DAG** work manager in a variety of ways. I can usually rely on this tool being available, or made easily available as it passes most screenings easily, quickly and adding / working with the various work nodes is straight forward and should be easy to parse. 

Nodes in the work tree can be tied together depending on dependency chains in various environments and can be skipped entirely.

## docker

Docker makes the rest of the tool chain usuable across environments aslong as they run the docer daemon. This also helps keep our environments clean, and testable with the ability to entirely refresh on every execution.

## aws cli

The aws cli gives me simple task management execution. Usually used for tests like posting to s3 buckets or triggering events manually.

## slack

Easy to use platform with incoming webhooks. No fuss, just an easy to use endpoint to trigger notifications and custom messages.

# What I Would Fix

So much..

1. Lots of IAM nonsense, and centralize it better in the rbac module
2. More consistent naming standard across module files
3. Lots more error handling and metrics based off them