# coding: utf8
import utils
import download_times as dt
import json

OUTPUT_PATH_COACHES = utils.OUTPUT_PATH + 'coaches.csv'
OUTPUT_PATH_COMPETITORS = utils.OUTPUT_PATH + 'competidores.csv'


def main():
  links = json.load(open(utils.LINKS_JSON_PATH, 'r'))
  for year in links:
    dt.download_competidor_data(links[year][utils.TEAM_KEY],
                                OUTPUT_PATH_COMPETITORS,
                                OUTPUT_PATH_COACHES)

if __name__ == '__main__':
  main()
