# coding: utf8
import utils
import download_statistics as ds
import json

OUTPUT_PATH = utils.OUTPUT_PATH + '../data/statistics'
STATISTICS_KEY = 'statistic_url'

def main():
  links = json.load(open(utils.LINKS_JSON_PATH, 'r'))
  for year in links:
    if 'statistic_url' in links[year]:
      print links[year][STATISTICS_KEY]
      ds.download_statistics(links[year][STATISTICS_KEY], '%s/%s/' % (OUTPUT_PATH, year))
    else:
      print "Ignoring %s because the statistics url doesn't exist :(" % year
if __name__ == '__main__':
  main()
