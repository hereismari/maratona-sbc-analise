'''
Utilidades para os scripts baixarem e iteragirem com os dados.
'''

import requests

def request_get(url):
  return requests.get(url).content
