import utils

import pandas as pd  # csv manipulation
import argparse  # use arguments


# -------------- Arguments -------------
parser = argparse.ArgumentParser()

URL_2017 = "http://maratona.ime.usp.br/resultados17/reports/statistics/Report%20Page.html"
parser.add_argument('--statistics_url', type=str, default=URL_2017,
                    help='URL to a BOCA STATISTICS.')

parser.add_argument('--output_path', type=str, default='../data/statistics/2017/',
                    help='Path to CSV folder.')


# -------------- Getting Statistics and Saving as CSV ------------------
def download_statistics(statistics_url, output_path):
  print 'Getting statistics from: %s' % statistics_url
  # request html
  html = utils.request_get(statistics_url)

  # save as dataframe
  # ignoreing first table because it is just the page header
  for df in pd.read_html(html)[1:len(pd.read_html(html))]:
    title = df.loc[0,0].lower().replace(' ', '_')
    print 'Saving as csv at %s' % output_path + title + '.csv'
    # save df as csv
    utils.save_as_csv(df, output_path + title + '.csv')


def main():
  args = parser.parse_args()
  download_statistics(args.statistics_url, args.output_path)


if __name__ == '__main__':
  main()
