import json


def lambda_handler(event, context):
    print(f"received event: {event}")
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "OK"})
    }
