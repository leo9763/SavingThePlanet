import requests, zlib, base64
import random, re, json
from datetime import datetime
from bs4 import BeautifulSoup
from getproxy import  get_proxy

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',}

class Singleton(object):
    _instance = None
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(Singleton, cls).__new__(cls,*args,**kwargs)
        return cls._instance

class CrawlWaimai(Singleton):
    def __init__(self):
        pass

    def get_timestamp(self):
        date_1970 = datetime(1970,1,1)
        date_now = datetime.now()
        date_interval = int((date_now - date_1970).total_seconds() * 1000)
        return  date_interval

    def encode_url(self, data, isStringify = False):
        if (isStringify == True):
            data_compressed = zlib.compress(data.encode())
            data_base64 = base64.b64encode(data_compressed)
            return data_base64
        else:
            data_json = json.dumps(data).replace(' ',"")
            return self.encode_url(data_json, True)

    def decode_url(self, data_encoded):
        if isinstance(data_encoded, str):
            data_compressed = base64.b64decode(data_encoded)
            data = zlib.decompress(data_compressed)
            return data

    def get_cities(self):
        return [{"city_name": "广州", "city_pinyin": "guangzhou", "city_id": 440100}]

        cities = []
        url = "http://i.waimai.meituan.com/ajax/v6/user/address/opencities"
        try:
            response = requests.post(url, headers = headers)
            if response.status_code == 200:
                cities_info = json.loads(response.text)
                for city_nav in cities_info['data']['city_nav']:
                    for city in city_nav['cities']:
                        cities.append(city)
            print(cities)
        except Exception as e:
            print(e)
        return cities

    def get_categories(self):
        return [{"code":0,"name":"全部品类","quantity":3541}]

        url = "http://i.waimai.meituan.com/ajax/v6/poi/getfilterconditions"

        categories = []
        sub_categories = []
        try:
            #910是美食品类的编号
            data = json.dumps({"navigate_type": 910, "first_category_type": 910, "second_category_type": 0})
            response = requests.post(url, headers = headers, data = data)
            if response.status_code == 200:
                categories_info = json.loads(response.text)
                for categories_filter in categories_info['data']['category_filter_list']:
                    for category in categories_filter['cities']:
                        categories.append({"code":category['code'],"name":category['name'],"quantity":category['quantity']})
        except Exception as e:
            print(e)
        return categories

    def get_restaurants(self, category = None, city = None):
        restaurants = []
        url = "http://i.waimai.meituan.com/ajax/v6/poi/filter?"

        if category is not None:
            url = url + "category_type="+category['code']
            url = url + "&category_text="+category['name']
        # else:
            # url = url + "category_type=0"

        # if city is not None:
            # url = url + "&lat=" + city['lat'] + "lng" + city["lng"]
        url = url + "lat=23.12908&lng=113.26436"

        _token = self.make_token()
        # url = url + "&second_category_type=0&_token=" + self.encode_url(_token).decode()
        url = url + "&_token=" + self.encode_url(_token).decode()

        try:
            data = {"uuid": "n0wvS3euIfxe6ZX1ZYrUWA2UIvtIkfZOwNyf0IlfI0ucgfu0eiWvM7Tul0_m17FB",
                    "platform": 3,
                    "partner": 4,
                    "page_index": 0,
                    "apage": 1,
                    "mtsi_font_css_version": "20ad699b"}

            response = requests.post(url , headers=headers, data=json.dumps(data), cookies=self.set_cookies())
            if response.status_code == 200:
                response.encoding = "utf-8"
                restaurants_info = json.loads(response.text)
                for restaurant_info in restaurants_info['data']['poilist']:
                    restaurants.append({"month_sale_num":restaurant_info["month_sale_num_encoded"],
                                        "name":restaurant_info["name"]})
        except Exception as e :
            print(e)
        return restaurants

    def make_token(self, city = None):
        apage = "1"
        category_type = "0"
        category_text = "美食"
        page_index = "0"

        sign = "apage="+ apage + "&lat=23.12908&lng=113.26436&page_index=0" #"&category_type=" + category_type + "&page_index=" + page_index + "&second_category_type=0"
        pre_url_1 = "http://i.waimai.meituan.com/mti/channel?category_type=0&second_category_type=0"
        pre_url_2 = "http://i.waimai.meituan.com/mti/channel?category_type=910&category_text=%E7%BE%8E%E9%A3%9F"
        _token = {"rId":100009,
                  "ver":"1.0.6",
                  "ts":self.get_timestamp(),
                  "cts":self.get_timestamp()+462,
                  "brVD":[375,812],
                  "brR":[[375,812],[375,812],24,24],
                  "bI":["http://i.waimai.meituan.com/home?lat=23.12908&lng=113.26436","http://i.waimai.meituan.com/city"],
                  "mT":[],
                  "kT":[],
                  "aT":[],
                  "tT":[],
                  "aM":"",
                  "sign":self.encode_url(sign).decode()
                  }
        return _token



#http://i.waimai.meituan.com/ajax/v6/poi/filter?lat=23.12908&lng=113.26436
# &_token=eJx9T01Pg0AQ/S9z8CJZ2OVDloQYTHuggY0KbdMYDxSx3cpSpasFGv+7Q1LTeHEyyZt58+brBG38AgG10LgBX1ULAVBiEQ8M0AesuI7leh53uM+ZAeVfjtvUgHW7mEDwZN+4hk/Z80g8Yn4hLhFz0EdFjALYav0emKYkx0KqQhJVSf1ZNKTcK3O7V9VtXeiQ2YQybvlXdbMJKbUJ8xx7vO6/7lLqHnCPynEP4tsZizPq3zzFd3HWQW4ajKpZl2eyi/PpNRWLPMmyvhN5skyHrBfJ3UPv14ke5pYQqyHdpZ2o08nHanc/TPWsXUd0HsXR8jUS5jEM4fsHtKZjvA==
#{"rId":100009,"ver":"1.0.6","ts":1540566949892,"cts":1540566949931,"brVD":[375,812],"brR":[[375,812],[375,812],24,24],"bI":["http://i.waimai.meituan.com/home?lat=23.12908&lng=113.26436","http://i.waimai.meituan.com/city"],"mT":[],"kT":[],"aT":[],"tT":[],"aM":"","sign":"eJxTSixITE+1NVTLSSyxNTLWMzSyNLBQy8lLtzU0NNYzMjMxNlMDqYjPzEtJrbA1UAIAWfAN/w=="}
#{"sign":"apage=1&lat=23.12908&lng=113.26436&page_index=0"}
#
#

    def set_cookies(self):
        from requests.cookies import RequestsCookieJar

        cookie_jar = RequestsCookieJar()
        cookie_jar.set("w_latlng", "23129080, 113264360")
        cookie_jar.set("w_cpy_cn", "%E5%B9%BF%E5%B7%9E")
        cookie_jar.set("w_cpy", "guangzhou")
        cookie_jar.set("w_cid", "440100")
        cookie_jar.set("w_addr", "%E5%B9%BF%E5%B7%9E%E5%B8%82-%E5%B9%BF%E4%B8%9C%E7%9C%81")
        cookie_jar.set("w_utmz", "utm_campaign=(direct)&utm_source=5000&utm_medium=(none)&utm_content=(none)&utm_term=(none)")
        cookie_jar.set("w_visitid", "540380bf-91e7-4346-ac6c-e8873b5e7692")
        cookie_jar.set("w_uuid", "n0wvS3euIfxe6ZX1ZYrUWA2UIvtIkfZOwNyf0IlfI0ucgfu0eiWvM7Tul0_m17FB")
        cookie_jar.set("terminal", "i")
        return cookie_jar



CrawlWaimai().get_restaurants()