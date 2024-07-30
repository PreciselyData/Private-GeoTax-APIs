import argparse
import re
import os
import base64
import json
import time
import requests
import urllib
import os.path
from builtins import bytes
from zipfile import ZipFile
import subprocess


def current_milli_time(): return int(round(time.time() * 1000))


COUNTRY_SPD_MAPPING = [
        "Vertex L-Series ASCII#United States#All USA#Spectrum Platform Data",
        "Payroll Tax Data#United States#All USA#Spectrum Platform Data",
        "Tax Rate Data ASCII#United States#All USA#Spectrum Platform Data",
        "Sovos Correspondence File ASCII#United States#All USA#Spectrum Platform Data",
        "Vertex O-Series ASCII#United States#All USA#Spectrum Platform Data",
        "GeoTAX Auxiliary File ASCII#United States#All USA#Spectrum Platform Data",
        "GeoTAX Premium Masterfile Monthly#United States#All USA#Spectrum Platform Data",
        "Vertex Q-Series ASCII#United States#All USA#Spectrum Platform Data",
        "Insurance Premium Tax Data#United States#All USA#Spectrum Platform Data",
        "Special Purpose District Data#United States#All USA#Spectrum Platform Data"
]

class DataDeliveryClient:
    auth_token = ''
    token_expiration = 0

    __api_host = 'https://api.precisely.com'

    api_url = __api_host + '/digitalDeliveryServices/v1/'
    auth_url = __api_host + '/oauth/token'
    pdx_api_url = __api_host + '/pdx/api/public/sdk/v1/'

    @property
    def api_host(self):
        return self.__api_host

    @api_host.setter
    def api_host(self, var):
        self.__api_host = 'https://' + var
        self.api_url = self.api_host + '/digitalDeliveryServices/v1/'
        self.auth_url = self.api_host + '/oauth/token'
        self.pdx_api_url = self.api_host + '/pdx/api/public/sdk/v1/'

    def __init__(self, api_key, shared_secret, app_id):
        self.api_key = api_key
        self.shared_secret = shared_secret
        self.app_id = app_id

    def get_deliveries(self, product_name, geography=None, roster_granularity=None, page_number=1, limit=None,
                       min_release_date=None, data_format=None, preferred_format: bool = False,
                       latest: bool = False):
        params = {}
        if latest:
            params['byLatest'] = True
        if product_name:
            params['ProductName'] = product_name
        if geography:
            params['geography'] = geography
        if roster_granularity:
            params['rosterGranularity'] = roster_granularity
        if page_number:
            params['pageNumber'] = int(page_number)
        if limit:
            params['pageSize'] = int(limit)
        if min_release_date:
            params['laterThanDate'] = min_release_date
        if data_format:
            params['dataFormat'] = data_format
        if preferred_format:
            params['preference'] = 'true'

        try:
            response = self.get(url=self.pdx_api_url + 'data-deliveries', params=params,
                                headers=self.create_headers())
            return json.loads(response.text)
        except Exception as exception:
            return exception

    def create_headers(self):
        return {
            'Authorization': 'Bearer ' + self.get_auth_token()
        }

    def get_auth_token(self):
        if not self.auth_token or current_milli_time() > self.token_expiration:
            self.get_new_auth_token()

        return self.auth_token

    def get_new_auth_token(self):

        params = {
            'grant_type': 'client_credentials'
        }

        headers = {
            'Authorization': 'Basic ' + base64.b64encode(
                bytes(self.api_key + ':' + self.shared_secret, 'utf-8')).decode('utf-8')
        }

        response = self.post(self.auth_url, headers, data=params)
        # print('Proxy server invoked')
        response_json = json.loads(response.text)

        if 'access_token' in response_json:
            self.auth_token = response_json['access_token']
            self.token_expiration = current_milli_time(
            ) + (int(response_json['expiresIn']) * 1000)
        else:
            raise Exception(
                'An error occurred getting authorization info, please check your api key and shared secret.')

    def post(self, url, headers=None, data=None):
        if headers is None:
            headers = {}
        if self.app_id:
            headers['x-pb-appid'] = self.app_id
            response = requests.post(url=url, data=data, headers=headers)
        return response

    def get(self, url, headers=None, params=None):
        if headers is None:
            headers = {}
        if self.app_id:
            headers['x-pb-appid'] = self.app_id
            response = requests.get(
                url, stream=True, headers=headers, params=params)
        return response


def unzip(path, zip_filename):
    with ZipFile(zip_filename, 'r') as handle:
        if len(os.listdir(path)) == 0:
            print("Extracting {:s} to {:s}".format(zip_filename, path))
            handle.extractall(path=path)
        else:
            print("Skipping extraction to {:s} as directory is not empty.".format(path))


def get_argument_parser():
    parser = argparse.ArgumentParser(description='Interacts with the Digital Data Delivery API.')
    parser.add_argument('--pdx-api-key', dest='pdx_api_key',
                        help='The API key provided by the Software and Data Marketplace portal.',
                        required=True)
    parser.add_argument('--pdx-api-secret', dest='pdx_api_secret',
                        help='The shared secret provided by the Software and Data Marketplace portal.',
                        required=True)
    parser.add_argument('--local-path', dest='local_path',
                        help='The base path for downloading and extracting spds locally.')
    parser.add_argument('--dest-path',
                        dest='dest_path',
                        help='The mount base path for extracting SPDs')
    parser.add_argument('--data-mapping',
                        dest='data_mapping',
                        help='Mapping of data in the form of dictionary',
                        default=COUNTRY_SPD_MAPPING,
                        type=json.loads,
                        required=False)
    return parser.parse_args()


def get_products(spd):
    product_list = list()
    pieces = spd.split('#')
    product_name = pieces[0]
    geography = pieces[1]
    roster_gran = pieces[2]
    data_format = pieces[3]
    by_latest = True
    vintage = None
    if len(pieces) > 4:
        by_latest = False
        vintage = pieces[4]
    try:
        search_results = client.get_deliveries(product_name, geography, roster_gran, 1, None, None, data_format,
                                               latest=by_latest)
        if 'errors' in search_results:
            raise Exception(f'An error occurred getting product information: {search_results}')

        try:
            if dict(search_results).get('deliveries', None) is None:
                raise Exception(f'Deliveries are not available for the product: {product_name}'
                                f'. Response from PDX: {search_results}')
            for delivery_info in search_results['deliveries']:
                if vintage is None or vintage == delivery_info['vintage']:
                    product_list.append((product_name, delivery_info['downloadUrl']))
        except Exception as exp:
            raise exp

    except Exception as exp:
        raise exp
    return product_list


def download_spds_to_local(products_list, spd_base_path):
    for name, url in products_list:
        download_file_name = re.sub(r'.*/(.+)\?.*', r'\1', url)
        file_path = os.path.join(spd_base_path, download_file_name)
        if not os.path.isfile(file_path):
            print('Downloading {:s} to {:s}'.format(download_file_name, file_path))
            urllib.request.urlretrieve(url, file_path)


def extract_spds_to_mount_path(spd_path_value, extract_path_value, current_date_folder):
    for f in os.listdir(spd_path_value):
        spd_path_local = os.path.join(spd_path_value, f)
        try:
            if f.endswith('.spd'):
                with ZipFile(spd_path_local, "r") as zip_ref:
                    data = zip_ref.read('metadata.json')
                    metadata = json.loads(data)
                    extract_path_spd = os.path.join(extract_path_value,
                                                    current_date_folder,
                                                    metadata['vintage'],
                                                    metadata['qualifier'])
                    os.makedirs(extract_path_spd, exist_ok=True)
                unzip(extract_path_spd, spd_path_local)
        except Exception as exp:
            raise exp


args = get_argument_parser()

PDX_API_KEY = args.pdx_api_key
PDX_SECRET = args.pdx_api_secret
LOCAL_PATH = args.local_path
COUNTRY_MAPPING = args.data_mapping
date_folder = str(time.strftime("%Y%m%d%H%M"))

if not COUNTRY_MAPPING:
    COUNTRY_MAPPING = COUNTRY_SPD_MAPPING

if not LOCAL_PATH:
    LOCAL_PATH = os.getcwd()

client = DataDeliveryClient(PDX_API_KEY, PDX_SECRET, "SDM_DEMO_APP_3.0.0")

extract_path = args.dest_path
if not args.dest_path:
    extract_path = "/mnt/data/geotax-data"
spd_path = os.path.join(LOCAL_PATH, "spds")

print(f"Provided products for Installation: {COUNTRY_SPD_MAPPING}")
os.makedirs(extract_path, exist_ok=True)
for product in COUNTRY_MAPPING:
    os.makedirs(spd_path, exist_ok=True)
    try:
        try:
            products = get_products(product)
            if not len(products):
                raise Exception(
                    "Either no Deliveries available for provided OR validate the parameters."
                    " To request access to the particular data, please visit https://data.precisely.com/")
        except Exception as ex:
            raise Exception(f'Exception while getting download url for {product}: {ex}', ex)

        try:
            download_spds_to_local(products, spd_path)
        except Exception as ex:
            raise Exception(f'Exception while downloading spds to local for {product}: {ex}', ex)

        spds = os.listdir(spd_path)
        if spds is None or len(spds) == 0:
            raise Exception(
                f"No spds available to extract for {product}, "
                f"please check if you have access for {product} "
                "or the pdx data is accessible.")

        try:
            extract_spds_to_mount_path(spd_path, extract_path, date_folder)
        except Exception as ex:
            raise Exception(f'Exception while extracting spds for {product}: {ex}', ex)

        try:
            print(f'Deleting local directories: {spd_path}')
            subprocess.check_output(f'rm -rf {spd_path}', shell=True)
        except subprocess.CalledProcessError as e:
            print(
                f"Unable to delete {spd_path} -> Exception: {e}, Output: {e.output}, "
                f"StdOut: {e.stdout}, StdErr: {e.stderr}")
    except Exception as ex:
        print(ex)
        print(f'Data download and extraction process is not successful for {product}. '
              f'Please run the setup again for {product} by fixing the issues.')
        pass
print(f"Data download and extraction is completed")

