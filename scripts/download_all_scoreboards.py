# coding: utf8
import utils
import download_scoreboard as ds
import json

OUTPUT_PATH = utils.OUTPUT_PATH + 'scoreboards'
SCOREBOARD_KEY = 'scoreboard_url'

def main():
  links = json.load(open(utils.LINKS_JSON_PATH, 'r'))
  for year in links:
    if not '_comment' in links[year]:
      ds.download_scoreboard(links[year][SCOREBOARD_KEY], '%s/%s.csv' % (OUTPUT_PATH, year))
    else:
      print 'Ignoring %s because the scoreboard is a pdf file :(' % year
if __name__ == '__main__':
  main()
