import utils
import argparse  # use arguments


# -------------- Arguments -------------
parser = argparse.ArgumentParser()

URL_2017 = "http://maratona.ime.usp.br/resultados17/reports/run-list/Report%20Page.html"
parser.add_argument('--submissoes_url', type=str, default=URL_2017,
                    help='URL to a BOCA RUN LIST.')

parser.add_argument('--output_path', type=str,
                    default='../data/submissoes/2017.csv',
                    help='Path to CSV.')


# -------------- Getting Submissions and Saving as CSV ------------------
def download_submissoes(submissoes_url, output_path):
  print 'Getting submissions from: %s' % submissoes_url
  # request html
  html = utils.request_get(submissoes_url)
  # save last table as dataframe
  df = utils.get_last_table(html)
  print 'Saving as csv at %s' % output_path
  # save df as csv
  utils.save_as_csv(df, output_path)


def main():
  args = parser.parse_args()
  download_submissoes(args.submissoes_url, args.output_path)


if __name__ == '__main__':
  main()
