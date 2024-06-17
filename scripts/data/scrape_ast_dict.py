import requests
from bs4 import BeautifulSoup
import re
from time import sleep
import os

BASE_URL = "https://diccionariu.alladixital.org/index.php?cod="

max_count=52000 #51846

if os.path.exists("dict.ast"):
    with open("dict.ast","r", encoding='utf-8') as file:
        count = len(file.read().splitlines())+1
else:
    count=1

while count <= max_count:
    # URL of the page you want to scrape
    url = BASE_URL+str(count)

    # Send a GET request to the page
    response = requests.get(url)

    # Parse the HTML content of the page with BeautifulSoup
    soup = BeautifulSoup(response.content, 'html.parser')

    results = soup.find("h3", string=re.compile("Resultaos"))

    try:
        definition = results.findNextSibling("p").get_text()
    except:
        definition = ""
        
    with open("dict.ast","a", encoding='utf-8') as file:
        file.write(definition.strip()+"\n")

    if count%30 == 0:
        sleep(3)
    
    if count%10 == 0:
        print(f"Scraped {count} pages")

    count+=1