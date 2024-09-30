import requests
from datetime import datetime

status_file = './logs/status.log'
log_file = './logs/error.log'

try:
    response = requests.get('http://127.0.0.1:8888/status')
    if response.status_code == 200:
        with open(status_file, 'w+') as file:
            file.write(f'SUCCESS: {datetime.now()}\n')
    else:
        with open(status_file, 'w+') as file:
            file.write(f'ERROR: {datetime.now()}\n')
        with open(log_file, 'a+') as file:
            file.write(f'ERROR: Received status {response.text} at {datetime.now()}\n')
except requests.exceptions.RequestException as exc:
    with open(status_file, 'w+') as file:
        file.write(f'ERROR: {datetime.now()}\n')
    with open(log_file, 'a+') as file:
        file.write(f'ERROR: {str(exc)} at {datetime.now()}\n')
