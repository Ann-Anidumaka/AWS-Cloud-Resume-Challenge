import boto3
#from boto3.dynamodb.conditions import Key
import os

def lambda_handler(event, context):
    
    TABLE_NAME = "cloud_resume"
    db_client = boto3.client('dynamodb')
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(TABLE_NAME)

    update = db_client.update_item(
        TableName=TABLE_NAME,
        Key={"id": {"N": "0"}},
        UpdateExpression="ADD views :inc",
        ExpressionAttributeValues={":inc": {"N": "1"}}
    )

    getItems = table.get_item(Key={"id": 0})
    itemsObjectOnly = getItems["Item"]
    visitcount = itemsObjectOnly["views"]

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