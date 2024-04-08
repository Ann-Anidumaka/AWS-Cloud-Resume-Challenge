import boto3
#from boto3.dynamodb.conditions import Key
import os

def lambda_handler(event, context):
    
    TABLE_NAME = "cloud_resume"
    db_client = boto3.client('dynamodb')
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(TABLE_NAME)

    response = table.update_item(
        Key={"id": 0},  # Ensure this matches the hash key used in Terraform
        UpdateExpression="SET views = if_not_exists(views, :start) + :inc",
        ExpressionAttributeValues={":inc": 1, ":start": 0},
        ReturnValues="UPDATED_NEW"
    )

    getItems = table.get_item(Key={"id": 0})
    itemsObjectOnly = getItems["Item"]
    views = itemsObjectOnly["views"]

    response = {
        "headers": {
            "content-type" : "application/json"
        },
        "status_code": 200,
        "body" : {
            "count": views
        }
    }

    return response