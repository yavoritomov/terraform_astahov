import urllib3

def lambda_handler(event, context):
    http = urllib3.PoolManager()
    resp = http.request('GET', 'https://api.zippopotam.us/us/77036')
    response = resp.json()
    print(response)
    return {
       'message' : response
    }