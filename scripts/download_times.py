"""Download competitions info and save as data/competidores.csv and
   data/coaches.csv.
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
                    help='URL to the main page of a SBC competition.')

parser.add_argument('--output_path_competidor', type=str,
                    default='../data/competidores.csv',
                    help='Path to competidor CSV.')
parser.add_argument('--output_path_coach', type=str,
                    default='../data/coaches.csv', help='Path to coach CSV.')


# ------------------ Global variables and constants -------------
CLASSIFIED = ['classificado para a final mundial',
              'classificado para o mundial']
SUBSTITUTE = '(reserva)'

COMPETITOR_CSV_HEADER = ['ano', 'time', 'competidor', 'reserva', 'classificado',
                         'posicao', 'medalha']
COACH_CSV_HEADER = ['ano', 'time', 'coach']

# hack for saving competitors position in a table
position = 1


# -------------- Getting Teams and save as CSV ------------------
def add_rows(df_competitors, df_coaches, soup, color, url):
  def get_text(soup_entity):
    '''This function gets a clean version of the text from a soup entity.'''
    return ' '.join([line.strip() for line in soup_entity.get_text().strip().splitlines()]).lower()

  def clean_competitor_name(name):
    '''Remove pontuation and leading white space.'''
    return name.strip().replace('.', '')

  # position will be incremented for each team
  global position

  # year can be found in the first font of all html
  year = soup.find("font").get_text().split()[-1]

  try:
    element = soup.find("font", {"color": color}).findParent()
    for children in element.findChildren():
      if children.name == 'li':
        team = get_text(children.a)
        competitors_text = re.sub(' +', ' ', get_text(children).split(':')[-1])

        # checking if team classified to the world finals
        classified = 0
        for c in CLASSIFIED:
          if c in competitors_text:
            competitors_text = competitors_text.replace(c, '')
            classified = 1

        competitors, coaches = re.split('coaches|coach', competitors_text)
        competitors = re.split(',| e ', competitors)
        coaches = re.split(',| e ', coaches)

        for i, c in enumerate(competitors):
          if len(c) <= 0:
            continue
          substitute = 0
          c = clean_competitor_name(c)
          if SUBSTITUTE in c:
              c = c.replace(SUBSTITUTE, '')
              substitute = 1
          row = [year, team, c, substitute, classified, position, color]
          df_competitors.loc[len(df_competitors)] = row

        for i, c in enumerate(coaches):
          c = clean_competitor_name(c)
          row = [year, team, c]
          df_coaches.loc[len(df_coaches)] = row
        position += 1
  except:
    print 'Year %s has data in a different format and will not be used.' % year


def generate_dataframes(url, soup, output_path_competitor, output_path_coach):
  df_competitors = utils.try_load_csv(output_path_competitor,
                                      COMPETITOR_CSV_HEADER)
  df_coaches = utils.try_load_csv(output_path_coach,
                                  COACH_CSV_HEADER)
  add_rows(df_competitors, df_coaches, soup, 'gold', url)
  add_rows(df_competitors, df_coaches, soup, 'silver', url)
  add_rows(df_competitors, df_coaches, soup, 'bronze', url)
  return df_competitors, df_coaches


def download_competidor_data(url, output_path_competitor, output_path_coach):
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
  utils.save_as_csv(df_competitors, output_path_competitor)

  print 'Saving as csv at %s' % output_path_coach
  utils.save_as_csv(df_coaches, output_path_coach)


def main():
  args = parser.parse_args()
  download_competidor_data(args.general_information_url,
                           args.output_path_competitor, args.output_path_coach)


if __name__ == '__main__':
  main()
