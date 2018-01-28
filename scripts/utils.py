"""General utilities in one place."""
import requests
import pandas as pd
import os

# ---------------- Constants -----------------------

# paths
OUTPUT_PATH = os.path.expanduser('~/maratona-sbc-analise/dados/')
LINKS_JSON_PATH = os.path.join(OUTPUT_PATH, 'links.json')
UNIVERSIDADES_PATH = os.path.join(OUTPUT_PATH, 'auxiliares/universidades.csv')
REGIOES_PATH = os.path.join(OUTPUT_PATH, 'auxiliares/regioes.csv')

# keys in LINKS_JSON
COMMENT_SCOREBOARD_KEY = '_comment_scoreboard_url'
SCOREBOARD_KEY = 'scoreboard_url'
SUBMISSOES_KEY = 'submissoes_url'
STATISTICS_KEY = 'statisticas_url'
TEAM_KEY = 'pagina_principal_url'
CLARIFICATIONS_KEY = 'clarifications_url'

# ---------------- HTML related ----------------
def request_get(url):
  return requests.get(url).content

def get_first_table(html):
    return pd.read_html(html)[0]

def get_last_table(html):
    return pd.read_html(html)[-1]


# ---------------- CSV related --------------------
def save_as_csv(df, output_path):
  # create directory if needed
  directory = os.path.dirname(output_path)
  if not os.path.exists(directory):
    os.makedirs(directory)
  # save dataframe as csv
  df.to_csv(output_path, encoding='utf-8', index=False)


def try_load_csv(output_path, columns):
  """Try load a csv as dataframe, if it does not exist create an empty one."""
  try:
    df = pd.read_csv(output_path)
    print('Loaded csv from', output_path)
  except:
    print('Creating dataframe since %s does not exist' % output_path)
    df = pd.DataFrame(columns=columns)
  return df
