import utils  # for http requests
import pandas as pd  # csv manipulation

import os
import argparse  # use arguments

# -------------- Arguments -------------

parser = argparse.ArgumentParser()

URL_2017 = "http://maratona.ime.usp.br/resultados17/reports/detailed-final-scoreboard/Report%20Page.html"
parser.add_argument('--scoreboard_url', type=str, default=URL_2017,
                    help='URL to a BOCA SCOREBOARD.')

parser.add_argument('--output_path', type=str, default='../data/scoreboards/2017.csv',
                    help='Path to CSV.')

# -------------- Getting Scoreboard and Saving as CSV ------------------
def save_as_csv(df, output_path):
  # create directory if needed
  directory = os.path.dirname(output_path)
  if not os.path.exists(directory):
    os.makedirs(directory)
  # save df as csv
  df.to_csv(output_path, encoding='utf-8', index=False)

def download_scoreboard(scoreboard_url, output_path):
  print 'Getting scoreboard from: %s' % scoreboard_url 
  # request html
  html = utils.request_get(scoreboard_url)

  # save as dataframe
  df = pd.read_html(html)[-1]

  print 'Saving as csv at %s' % output_path
  # save df as csv
  save_as_csv(df, output_path)

def main():
  args = parser.parse_args()
  download_scoreboard(args.scoreboard_url, args.output_path)


if __name__ == '__main__':
  main()


