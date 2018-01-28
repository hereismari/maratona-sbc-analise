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


def load_csv(path):
  return pd.read_csv(path)


def print_info(df):
    print(df.head(5))


# -------------- Manipulate data related ------------
def clean_data_map_values(df, column, inconsistencies):
  for k in inconsistencies:
    df.loc[df[column].isin([k]), column] = inconsistencies[k]
  return df


def clean_universidade(df):
    '''There are a coulpe of inconsistencies in the data.

         1. DCC-UFRJ -> UFRJ
         2. USP-SãO-PAULO -> USP-SP
         3. USP-SãO-CARLOS -> USP-SC
         4. DCC-UFRJ-NOP -> UFRJ
         5. EP-USP -> POLI-USP
         6. USP -> USP-SP
         7. ICMC-USP -> USP-SC
         8. UNICAMP-ALFA -> UNICAMP
         9. IC-UNICAMP -> UNICAMP

    '''
    inconsistencies  = {
        'DCC-UFRJ': 'UFRJ',
        'USP-SÃO-PAULO': 'USP-SP',
        'USP-SÃO-CARLOS': 'USP-SC',
        'DCC-UFRJ-NOP': 'UFRJ',
        'EP-USP': 'POLI-USP',
        'USP': 'USP-SP',
        'ICMC-USP': 'USP-SC',
        'UNICAMP-ALFA': 'UNICAMP',
        'IC-UNICAMP': 'UNICAMP'
    }
    return clean_data_map_values(df, 'universidade', inconsistencies)


def clean_time(df):
    '''There are a coulpe of inconsistencies in the data.

         1. dcc ufrj nop -> nop
    '''
    inconsistencies  = {
        'dcc ufrj nop': 'nop'
    }
    return clean_data_map_values(df, 'time', inconsistencies)


def add_universidade_column(df):
    # this deals with some different cases like --
    df['time'] = [s.replace('--', '-') for s in df['time']]
    df['universidade'] = [s.split(' - ')[0].replace(' ', '-').upper() for s in df['time']]
    return clean_universidade(df)


def add_time_column(df):
    df['time'] = [s.split(' - ')[-1] for s in df['time']]
    return clean_time(df)
