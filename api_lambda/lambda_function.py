import json
import boto3
import requests

# Changes the state if we get post request from the sensor
def change_state(state):
    
    client = boto3.client('dynamodb')
    respones = client.update_item(
        TableName="shrub_state",
        Key={"nonce": {"S": "earthquake"}},
        AttributeUpdates={"state" : {
            "Value": {"S": str(state)},
            "Action": "PUT",
        }}
        )

# Gets the current state
def get_state():
    client = boto3.client('dynamodb')
    respones = client.get_item(
        TableName="shrub_state",
        Key={"nonce": {"S": "earthquake"}},
        AttributesToGet=["state"],
        )
    return respones["Item"]["state"]["S"]

# Main Function - handles post request
def lambda_handler(event, context):

    if event["httpMethod"]=="GET":
        return_body = json.dumps({
            'state': int(get_state()),
        })
        
    elif event["httpMethod"]=="POST":
        request_data = json.loads(event["body"])
        newState = request_data["newState"]
        change_state(newState)
        return_body = json.dumps({
            'state': int(get_state()),
        })

    return {
        'statusCode': 200,
        'body': return_body
    }
