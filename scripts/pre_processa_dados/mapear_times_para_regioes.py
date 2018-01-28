# encoding: utf-8

import os
import sys

# to import utils
sys.path.append('../')

import pandas as pd
import utils


def get_competidores_data(competidores_path='competidores.csv'):
    return pd.read_csv(os.path.join(utils.OUTPUT_PATH, competidores_path))


def get_universidades_data():
    df = pd.read_csv(utils.UNIVERSIDADES_PATH)
    df['sigla'] = [s.upper() for s in df['sigla']]
    print df['sigla']
    return df


def get_regioes_data():
    return pd.read_csv(utils.REGIOES_PATH)


def clean_universidade(df):
    '''There are a coulpe of inconsistencies in the data.

         1. DCC-UFRJ -> UFRJ
         2. USP-SãO-PAULO -> USP-SP
         3. USP-SãO-CARLOS -> USP-SC
         4. DCC-UFRJ-NOP -> UFRJ

    '''
    inconsistencies  = {
        'DCC-UFRJ': 'UFRJ',
        'USP-SãO-PAULO': 'USP-SP',
        'USP-SãO-CARLOS': 'USP-SC',
        'DCC-UFRJ-NOP': 'UFRJ'
    }
    for k in inconsistencies:
        df.loc[df.universidade.isin([k]), 'universidade'] = inconsistencies[k]

    return df


def clean_time(df):
    '''There are a coulpe of inconsistencies in the data.

         1. DCC-UFRJ-NOP -> nop
    '''
    inconsistencies  = {
        'DCC-UFRJ-NOP': 'nop'
    }
    for k in inconsistencies:
        df.loc[df.time.isin([k]), 'time'] = inconsistencies[k]
    return df


def make_universidade_column(df):
    # this deals with some different cases like --
    df['time'] = [s.replace('--', '-') for s in df['time']]
    df['universidade'] = [s.split(' - ')[0].replace(' ', '-').upper() for s in df['time']]
    return clean_universidade(df)


def make_time_column(df):
    df['time'] = [s.split(' - ')[-1] for s in df['time']]
    return clean_time(df)


def make_estado_column(df_competidor, df_universidade):
    df_competidor['estado'] = [df_universidade.loc[df_universidade['sigla'] == e]['estado'].iloc[0]
                               for e in df_competidor['universidade']]
    return df_competidor


def make_regioes_column(df_competidor, df_regioes):
    df_competidor['regiao'] = [df_regioes.loc[df_regioes['sigla'] == e]['regiao'].iloc[0]
                               for e in df_competidor['estado']]
    return df_competidor


def main():
    df_competidor = get_competidores_data()
    df_universidade = get_universidades_data()
    df_regioes = get_regioes_data()

    print df_competidor[df_competidor['time'] == 'dcc-ufrj - using namespace none;']

    df_competidor = make_universidade_column(df_competidor)
    df_competidor = make_time_column(df_competidor)
    df_competidor = make_estado_column(df_competidor, df_universidade)

    df_competidor = make_regioes_column(df_competidor, df_regioes)

    print df_competidor[df_competidor['time'] == 'using namespace none;']

if __name__ == '__main__':
    main()
