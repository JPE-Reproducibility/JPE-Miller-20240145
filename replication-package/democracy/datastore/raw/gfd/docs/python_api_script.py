# Script for pulling data from the GFD Series API
# Author: Jonathan Grundy and Robert Mohr, GFD Data Scientists
# Written in Python 2

import requests
import pandas as pd
import datetime
import os
import getpass

#Login

def gfd_auth(username = None, password = None):
    """
    Pulls a GFD API token and stores it as an environmental variable.
    
    Parameters
        username: GFD-approved email address.

        password: Password for GFD-approved email address.
    """
    if username is None:
        username = getpass.getpass('Please enter your GFD Finaeon username: ')

    if password is None:
        password = getpass.getpass('Please enter your GFD Finaeon password: ')

    url = 'https://api.globalfinancialdata.com/login/'
    parameters = {'username': username, 'password': password}
    resp = requests.post(url, data = parameters)

    #check for unsuccessful API returns
    if resp.status_code != 200:
        raise ValueError('GFD API request failed with HTTP status code %s' % resp.status_code)

    json_content = resp.json()
    os.environ['GFD_API_TOKEN'] = json_content['token'].strip('"')
    print("GFD API token recieved at %s" % str(datetime.datetime.now()))

# call the gfd_auth function with credentials
gfd_auth()

# Multi Series API with Price Data

# url for accessing the GFD series API
url = 'https://api.globalfinancialdata.com/series'

# parameters list for series API
# changing the token parameter here isn't necessary since the running the gfd_auth() function creates and stores the token
parameters = {'token': os.environ['GFD_API_TOKEN'],
              'seriesname': '_SPXD',
#               'seriesid': '',
#               'startdate': '',
#               'endate': '',
              'periodicity': 'Daily',
#               'closeonly': None,
#               'splitadjusted': None,
#               'currency': '',
#               'inflationadjusted': '',
#               'annualflow': False,
              'totalreturn': False,
#               'corporateactions': False,
#               'metadata': '',
#               'includeaverage': '',
#               'periodpercentchange': ''
             }

#API call return body
r = requests.post(url, data = parameters)
print(r)

#extracts the price data and assigns it to a pandas dataframe and exports file to local directory
data = pd.DataFrame(r.json()['price_data'])
data = data[['series_id', 'date', 'open', 'high', 'low', 'close', 'openint', 'volume']]
data.to_csv('api_data.csv', index=False)

# Search API

# parameters formatted for POST call
params = {'token': str(os.environ['GFD_API_TOKEN']),
          'searchstring': '_SPXD',
          'searchtype': 'symbol',
          'basefilter': 'exactmatch',
          'sort': 'pop',
          'page': '',
          'pagesize': 20}

# POST call
url = 'https://beta.globalfinancialdata.com/api/search/'
resp = requests.post(url, data=params)

json_content = resp.json()