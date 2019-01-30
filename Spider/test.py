import requests, zlib, base64
import random, re, json
from datetime import datetime
from bs4 import BeautifulSoup
from getproxy import  get_proxy


def encode_url(data, isStringify=False):
    if (isStringify == True):
        data_compressed = zlib.compress(data.encode())
        data_base64 = base64.b64encode(data_compressed)
        return data_base64
    else:
        data_json = json.dumps(data).replace(' ', "")
        data_url = encode_url(data_json, True)


def decode_url(data_encoded):
    if isinstance(data_encoded, str):
        data_compressed = base64.b64decode(data_encoded)
        data = zlib.decompress(data_compressed)
        return data

sign = "eJxTSixITE+1NVTLSSyxNTLWMzQyszQ0U8vJS7c1NDTWMzI1AnFBauIz81JSK2wNlQByMw5p"
result1 = decode_url(encode_url(sign))
print(result1)

original_sign = "apage=1&category_type=0&page_index=0&second_category_type=0"
result2 = decode_url(encode_url(original_sign))
print(result2)

# token:
# eJydkNtKw0AQht9lIL1pSDaJOUKQiAmmnmgaUlSkrNttu5hTk20OiO/uFipWLx0G/
# plvhuFnPqCJ1+BpSIQrQ0cb8EBTkGKBDLwVE9NwLMvUHdPQTRnIL2YhZMvw1mTX4L
# 3Ypi5ryNJfjyQR4IyclfqFyONOLFZgx3ntqSpTeswKzJSCMn7ApUKqQi04U8kOlyX
# NLwnmdFs144qPNfXRpKWkKterP1h4/t9BV0OTH0IH7kuhLV2FkhNKoSsFhuRGIEwX
# qTAt9P2k+KT8u78X7xMuWrYtRUVnQ7pgQ5yGU+0hS+5SNsxS4nT7qu/2iyHmaTYP+
# vLmeYrzOnoKHsmyHje5ebuJKlzPgyYJl1nv+/D5BRBXgbM=

# sign:
# eJxTSixITE+1NVRLTixJTc8vqowvqSxItTVQAwnHZ+alpFYAOcWpyfl5KfFoapQArREWVw==
# {"sign":"apage=1&category_type=0&page_index=0&second_category_type=0"}