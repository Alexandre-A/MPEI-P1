import pandas as pd
import numpy as np
import re

def data_init(source,output_file,percentage = 1):
    dataset = pd.read_csv(source)
    #print(dataset["type"].unique())
    if percentage < 1.0:
        rng = np.random.default_rng()  
        random_seed = rng.integers(0, 2**32) 
        dataset = dataset.sample(frac=percentage, random_state=random_seed)

    # Adjusting the overall dataset to our needs
    dataset = dataset.dropna() #remove rows with null values
    if (source == "original_malicious_phish.csv"):
        rem = {"type": {"defacement":"malign","phishing":"malign","malware":"malign"}}
        
    dataset = dataset.replace(rem)
    dataset['url'] = dataset['url'].replace('www.', '', regex=True) #Standardizing url names
    
    dataset.info()
    save_processed_data(dataset,output_file)    

    print(f"The processed dataset has been saved as '{output_file}'.")


def load_processed_data(csv_file):
    dataset = pd.read_csv(csv_file)
    return dataset

def save_processed_data(dataset,csv_file):
    dataset.to_csv(csv_file, index=False)

def having_ip_address(url):
    # Regex for detecting IPv4 and IPv6 addresses (with ports or CIDR notation)
    ip_regex = (
        r'(\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))'  # IPv4
        r'(\:\d+)?(\/\d{1,2})?\b|'  # Optional port or CIDR
        r'(\b0x([0-9a-fA-F]{1,2})\.){3}(0x[0-9a-fA-F]{1,2})\b|'  # IPv4 in hexadecimal
        r'\b([a-fA-F0-9]{1,4}:){7}[a-fA-F0-9]{1,4}\b'  # IPv6
    )
    return 1 if re.search(ip_regex, url) else 0

def Shortening_Service(url):
    shortening_services = [
        'bit.ly', 'goo.gl', 'shorte.st', 'go2l.ink', 'x.co', 'ow.ly', 't.co', 'tinyurl', 'tr.im', 'is.gd',
        'cli.gs', 'yfrog.com', 'migre.me', 'ff.im', 'tiny.cc', 'url4.eu', 'twit.ac', 'su.pr', 'twurl.nl',
        'snipurl.com', 'short.to', 'BudURL.com', 'ping.fm', 'post.ly', 'Just.as', 'bkite.com', 'snipr.com',
        'fic.kr', 'loopt.us', 'doiop.com', 'short.ie', 'kl.am', 'wp.me', 'rubyurl.com', 'om.ly', 'to.ly',
        'bit.do', 'lnkd.in', 'db.tt', 'qr.ae', 'adf.ly', 'bitly.com', 'cur.lv', 'tinyurl.com', 'ity.im',
        'q.gs', 'po.st', 'bc.vc', 'twitthis.com', 'u.to', 'j.mp', 'buzurl.com', 'cutt.us', 'u.bb',
        'yourls.org', 'prettylinkpro.com', 'scrnch.me', 'filoops.info', 'vzturl.com', 'qr.net', '1url.com',
        'tweez.me', 'v.gd', 'link.zip.net'
    ]

    malicious_shorteners = [
        'bit.ly', 'goo.gl', 'shorte.st', 'adf.ly', 'tinyurl', 'ow.ly', 't.co', 'is.gd', 
        'tr.im', 'q.gs', 'bc.vc', 'u.to', 'j.mp', 'cutt.us', 'ity.im', 'cur.lv'
    ]
    
    return int(any(service in url for service in malicious_shorteners))


def feature_engineering_data(dataset):
    spec_chars = ['@','?','-','=','.','#','%','+','$','!','*',',','//']

    if not 'Length' in dataset:
        dataset["Length"] = dataset['url'].apply(lambda x:len(str(x)))

    if not 'hasHTTPS' in dataset:
        dataset["hasHTTPS"] = dataset['url'].apply(lambda x: 1 if ("https://" in x) else 0)

    if not 'hasHTTP' in dataset:
        dataset["hasHTTP"] = dataset['url'].apply(lambda x: 1 if ("http://" in x) else 0)

    if not 'nDigits' in dataset:
        dataset["nDigits"] = dataset['url'].apply(lambda x: sum(1 for i in x if i.isnumeric()))

    for char in spec_chars:
        if not char in dataset:
            dataset[char] = data['url'].apply(lambda i: i.count(char))

    if not 'hasIPaddress' in dataset:
        dataset['hasIPaddress'] = dataset['url'].apply(lambda i: having_ip_address(i))

    if not 'shorteningServices' in dataset:
        dataset['shorteningServices'] = dataset['url'].apply(lambda i: Shortening_Service(i))



    
#-----------------------------------------------------#
source = "original_malicious_phish.csv"
final_data = "urlDataset.csv"

#Uncomment if needed to load to the device or change initial dataset
#data_init(source,final_data)

#Uncoment if needed to change portion of the initial dataset used
percentage = 0.5
data_init(source,final_data,percentage)

data = load_processed_data(final_data)

feature_engineering_data(data)
save_processed_data(data,final_data)
print(data.head(20))
