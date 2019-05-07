from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import pandas as pd
import time
import re
import csv
import os

###OPEN THE DRIVER
driver = webdriver.Chrome(r'C:\Users\cdcas\OneDrive\Documents\Professional\Bootcamp\Class\Projects\Selenium - NPR\chromedriver.exe')
driver.get("https://podcasts.apple.com/us/podcast/latino-usa/id79681317#see-all/reviews")
driver.maximize_window()
driver.implicitly_wait(30)

csv_file = open('test.csv', 'w', encoding='utf-8')
writer = csv.writer(csv_file)

###PREP DICTIONARY
review_dict = {}
review_dict['Title'] = 'Title'
review_dict['Date'] = 'Date'
review_dict['User'] = 'User'
review_dict['Body'] = 'Body'
review_dict['Rating'] = 'Rating'
writer.writerow(review_dict.values())

###SCROLL THE PAGE
SCROLL_PAUSE_TIME = 0.5
while True:
        # Get scroll height
        ### This is the difference. Moving this *inside* the loop
        ### means that it checks if scrollTo is still scrolling
    last_height = driver.execute_script("return document.body.scrollHeight")
        # Scroll down to bottom
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        # Wait to load page
    time.sleep(SCROLL_PAUSE_TIME)
        # Calculate new scroll height and compare with last scroll height
    new_height = driver.execute_script("return document.body.scrollHeight")
    if new_height == last_height:
            # try again (can be removed)
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            # Wait to load page
        time.sleep(SCROLL_PAUSE_TIME)
            # Calculate new scroll height and compare with last scroll height
        new_height = driver.execute_script("return document.body.scrollHeight")
            # check if the page height has remained the same
        if new_height == last_height:
                # if so, you are done
            break
            # if not, move on to the next loop
        else:
            last_height = new_height
            continue

###FIND BOX XPATHS
rev_box = driver.find_elements_by_xpath('//div[@class="we-customer-review lockup ember-view"]')
for box in rev_box:
    rev_title = box.find_element_by_xpath('.//h3[@class="we-truncate we-truncate--single-line ember-view we-customer-review__title"]').text
    rev_body = box.find_element_by_xpath('.//div[@class="we-clamp ember-view"]').text
    rev_date = box.find_element_by_xpath('.//time[@class="we-customer-review__date"]').text
    rev_user = box.find_element_by_xpath('.//span[@class="we-truncate we-truncate--single-line ember-view we-customer-review__user"]').text
    rev_star = box.find_element_by_xpath('.//span[@class="we-star-rating-stars-outlines"]/span[1]').get_attribute('class')
    rev_star = rev_star.replace('we-star-rating-stars we-star-rating-stars-',"")
    review_dict['Title'] = rev_title
    review_dict['Date'] = rev_date
    review_dict['User'] = rev_user
    review_dict['Body'] = rev_body
    review_dict['Rating'] = rev_star
    writer.writerow(review_dict.values())
    print(review_dict)

csv_file.close()
driver.close()
