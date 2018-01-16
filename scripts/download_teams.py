"""Download and save data/competitors.csv and data/coaches.csv."""

import utils  # for http requests
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

parser.add_argument('--output_path_competitor', type=str,
                    default='../data/competitors.csv',
                    help='Path to competitor CSV.')
parser.add_argument('--output_path_coach', type=str,
                    default='../data/coaches.csv', help='Path to coach CSV.')


# -------------- Getting Scoreboard and Saving as CSV ------------------
CLASSIFIED = 'Classificado para a final mundial'
SUBSTITUTE = '(reserva)'

COMPETITOR_CSV_HEADER = ['ano', 'time', 'competidor', 'reserva', 'classificado',
                         'link_foto', 'posicao', 'medalha']

COACH_CSV_HEADER = ['ano', 'time', 'coach']

position = 1


def save_as_csv(df_competitors, output_path):
  # create directory if needed
  directory = os.path.dirname(output_path)
  if not os.path.exists(directory):
    os.makedirs(directory)
  # save df_competitors as csv
  df_competitors.to_csv(output_path, encoding='utf-8', index=False)


def try_load_csv(output_path, columns):
  try:
    df_competitors = pd.read_csv(output_path)
  except:
    # create empty dataframe
    df_competitors = pd.DataFrame(columns=columns)
  return df_competitors


def generate_dataframes(url, soup, output_path_competitor, output_path_coach):
  df_competitors = try_load_csv(output_path_competitor,
                                COMPETITOR_CSV_HEADER)
  df_coaches = try_load_csv(output_path_coach,
                            COACH_CSV_HEADER)
  add_rows(df_competitors, df_coaches, soup, 'gold', url)
  add_rows(df_competitors, df_coaches, soup, 'silver', url)
  add_rows(df_competitors, df_coaches, soup, 'bronze', url)
  return df_competitors, df_coaches


def get_text(k):
  return ' '.join([line.strip() for line in k.get_text().strip().splitlines()])


def add_rows(df_competitors, df_coaches, soup, color, url):
  global position
  ano = soup.find("font").get_text().split()[-1]

  x = soup.find("font", {"color": color}).findParent()

  for k in x.findChildren():
    if k.name == 'li':
      photo_link = url + k.a['href']
      time = get_text(k.a)
      competitors_text = re.sub(' +', ' ', get_text(k).split(':')[-1])
      # checking if team classified to the world finals
      classified = 0
      if CLASSIFIED in competitors_text:
        competitors_text = competitors_text.replace(CLASSIFIED, '')
        classified = 1

      competitors, coaches = re.split('coaches|coach', competitors_text)
      competitors = re.split(',| e ', competitors)
      coaches = re.split(',| e ', coaches)

      for i, c in enumerate(competitors):
        substitute = 0
        c = re.sub(' +', ' ', c)  # remove double spaces
        if SUBSTITUTE in c:
            c = c.replace(SUBSTITUTE, '')
            substitute = 1
        row = [ano, time, c, substitute, classified, photo_link, position,
               color]
        df_competitors.loc[len(df_competitors)] = row

      for i, c in enumerate(coaches):
        c = re.sub(' +', ' ', c)  # remove double spaces
        row = [ano, time, c]
        df_coaches.loc[len(df_coaches)] = row
      position += 1


def download_competitor_data(url, output_path_competitor, output_path_coach):
  global position
  position = 1
  print 'Getting competitors from: %s' % url
  # request html
  html = utils.request_get(url)
  soup = BeautifulSoup(html, 'lxml')

  df_competitors, df_coaches = generate_dataframes(url, soup,
                                                   output_path_competitor,
                                                   output_path_coach)

  print 'Saving as csv at %s' % output_path_competitor
  save_as_csv(df_competitors, output_path_competitor)

  print 'Saving as csv at %s' % output_path_coach
  save_as_csv(df_coaches, output_path_coach)


def main():
  args = parser.parse_args()
  download_competitor_data(args.general_information_url,
                           args.output_path_competitor, args.output_path_coach)


if __name__ == '__main__':
  main()
