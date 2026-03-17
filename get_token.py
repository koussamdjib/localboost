import urllib.request, json
req = urllib.request.Request(
    'https://sirius-djibouti.com/api/v1/auth/token/',
    method='POST',
    headers={'Content-Type': 'application/json'},
    data=json.dumps({'email': 'ahmed.client.test@example.com', 'password': 'TestPass1234!'}).encode()
)
resp = urllib.request.urlopen(req, timeout=10)
data = json.load(resp)
print(data.get('access', 'ERROR'))
