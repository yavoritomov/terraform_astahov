import requests
def lambda_handler(event, context):
    response = requests.get("https://api.zippopotam.us/us/77042")
    print(response.text)
    return response.text