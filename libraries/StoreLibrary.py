import requests


def store_parsed_data(payload):
    result = requests.post('https://searchandstore.free.beeceptor.com', data={'ucc_data': payload})
