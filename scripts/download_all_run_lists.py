# coding: utf8

import download_run_list as dr
import json

LINKS_JSON_PATH = '../data/links.json'
OUTPUT_PATH = '../data/run_lists'
RUN_LIST_KEY = 'runs_url'

def main():
  links = json.load(open(LINKS_JSON_PATH, 'r'))
  for year in links:
    if 'runs_url' in links[year]:
      dr.download_run_list(links[year][RUN_LIST_KEY], '%s/%s.csv' % (OUTPUT_PATH, year))
    else:
      print "Ignoring %s because the run list url doesn't exist :(" % year
if __name__ == '__main__':
  main()
