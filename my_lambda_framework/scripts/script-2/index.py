import requests

def lambda_handler(event, context):
    resp = requests.get('https://api.zippopotam.us/us/77004')
    response = resp.json()
    record = response
    print(record)
    return {
       'message' : record
    }