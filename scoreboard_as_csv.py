import requests  # for http requests
import pandas as pd  # csv manipulation

import os
import argparse  # use arguments

# -------------- Arguments -------------

parser = argparse.ArgumentParser()

URL_2017 = "http://www.bombonera.org/score2017f2/score/#"
parser.add_argument('--scoreboard_url', type=str, default=URL_2017,
                    help='URL to a BOCA SCOREBOARD.')

parser.add_argument('--output_path', type=str, default='scoreboards/2017.csv',
                    help='Path to CSV.')

args = parser.parse_args()
# -------------- Getting Scoreboard and Saving as CSV ------------------
def save_as_csv(df):
  # create directory if needed
  directory = os.path.dirname(args.output_path)
  if not os.path.exists(directory):
    os.makedirs(directory)
  # save df as csv
  df.to_csv(args.output_path, encoding='utf-8', index=False)


print 'Getting scoreboard from: %s' % args.scoreboard_url 
# request html
html = requests.get(args.scoreboard_url).content

# save as dataframe
df = pd.read_html(html)[-1]

print 'Saving as csv at %s' % args.output_path
# save df as csv
save_as_csv(df)
