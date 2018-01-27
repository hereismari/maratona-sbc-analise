# coding: utf8
"""Download regional champions info and save as data/regions_champs/2017.csv.
 """
import utils

import pandas as pd  # csv manipulation
import os
import argparse  # use arguments
import re
from bs4 import BeautifulSoup


# -------------- Arguments -------------
parser = argparse.ArgumentParser()

URL_2017 = "http://maratona.ime.usp.br/resultados17/"
parser.add_argument('--general_information_url', type=str, default=URL_2017,
                    help='URL to the main page of a competition.')

parser.add_argument('--output_path_regional_champions', type=str,
                    default='../data/regions_champs/2017.csv',
                    help='Path to regional champions CSV.')

# ------------------ Global variables and constants -------------
REGIONAL_CHAMPIONS_TEXT = ['Foram reconhecidos os campeões regionais:', 'Neste ano foram reconhecidos os campeões regionais:']

REGIONAL_CHAMPIONS_CSV_HEADER = ['ano', 'universidade', 'time', 'regiao']


# -------------- Getting Teams and save as CSV ------------------
def add_rows(df_region_champs, soup, url):
  def get_text(soup_entity):
    '''This function gets a clean version of the text from a soup entity.'''
    return ' '.join([line.strip() for line in soup_entity.get_text().strip().splitlines()])

  # year can be found in the first font of all html
  year = soup.find("font").get_text().split()[-1]

  try:
    element = soup.find_all("p")
    for e in element:
        # remove line breaks and encode to utf-8
        text = e.get_text().replace('\r', '').replace('\n', '').encode('utf-8')

        if text in REGIONAL_CHAMPIONS_TEXT:
          for children in e.nextSibling.findChildren():
              if children.name == 'li':
                region = get_text(children).split(' - ')[0]
                university, team = get_text(children.a).split(' - ')

                row = [year, university, team, region]
                df_region_champs.loc[len(df_region_champs)] = row

  except:
    print 'Year %s has data in a different format and will not be used.' % year


def generate_dataframes(url, soup, output_path_regional_champions):
  df_region_champs = utils.try_load_csv(output_path_regional_champions,
                                        REGIONAL_CHAMPIONS_CSV_HEADER)
  add_rows(df_region_champs, soup, url)
  return df_region_champs


def download_regions_champions_data(url, output_path_regional_champions):
  print 'Getting region champions from: %s' % url
  # request html
  html = utils.request_get(url)
  soup = BeautifulSoup(html, 'lxml')

  df_region_champs = generate_dataframes(url, soup, output_path_regional_champions)

  print 'Saving as csv at %s' % output_path_regional_champions
  utils.save_as_csv(df_region_champs, output_path_regional_champions)


def main():
  args = parser.parse_args()
  download_regions_champions_data(args.general_information_url, args.output_path_regional_champions)


if __name__ == '__main__':
  main()
