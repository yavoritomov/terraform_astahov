import requests

def lambda_handler(event, context):
    resp = requests.get('https://reqres.in/api/users')
    response = resp.json()
    record = response['data'][0]
    print(record)
    return {
       'message' : record
    }