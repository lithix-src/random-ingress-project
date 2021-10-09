import json
import logging
import os
import boto3

from urllib.request import Request, urlopen, URLError, HTTPError

# read all the environment variables
SLACK_WEBHOOK_URL = os.environ['SLACK_WEBHOOK_URL']
SLACK_CHANNEL = os.environ['SLACK_CHANNEL']
SLACK_USER = os.environ['SLACK_USER']

s3 = boto3.resource('s3')
cloudwatch_events = boto3.client('cloudwatch')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Event: " + str(event))
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    obj = s3.Object(bucket_name, key)

    obj_data = obj.get()['Body'].read().decode('utf-8')

    try:
        msg_title = "sensor data"

        msg = "ingress bucket received: " + str(key)
        sensor_data = [int(i) for i in obj_data.split(',')]
        fake_math = sum(sensor_data)

        msg += "\n sensor data: " + str(fake_math)

        metric_details = [
            {
                'Name': 'sensor_data',
                'Value': 'aggregate'
            }
        ]

        cloudwatch_events.put_metric_data(
                Namespace = 'Ingress Project',
                MetricData=[{
                    'MetricName': 'Sensor Data',
                    'Dimensions': metric_details,
                    'Value': fake_math,
                    'Unit': 'Count'
                }])

        cloudwatch_events.put_metric_data(
                Namespace = 'Ingress Project',
                MetricData=[{
                    'MetricName': 'Sensor Data Drops',
                    'Dimensions': metric_details,
                    'Value': 1,
                    'Unit': 'Count'
                }])

    except Exception as e:
        # we assume all exceptions indicate a possible
        # error with the equipment and should alarm
        # for review
        msg_title = "sensor error"

        msg = "unable to parse sensor data: %s" % key
        msg += "\n error: %s" % (e)
        msg += "\n msg data: %s" % (obj_data)
        
        metric_details = {"sensor_data": 0}

        logger.error(msg)
        pass

    # construct a new slack message
    logger.info(msg)
    slack_message = {
        'channel': SLACK_CHANNEL,
        'user': SLACK_USER,
        'attachments':[{
            'fields': [{
                'title': "%s" % (msg_title),
                'value': "%s" % (msg)
            }]
        }]
    }
    
    # post message on SLACK_WEBHOOK_URL
    data = json.dumps(slack_message)
    req = Request(SLACK_WEBHOOK_URL, data.encode("utf-8"))

    try:
        response = urlopen(req)
        response.read()
        logger.info("Message posted to %s", slack_message['channel'])
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)
