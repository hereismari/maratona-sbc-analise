# coding: utf8
import utils
import download_statisticas as ds
import json

OUTPUT_PATH = utils.OUTPUT_PATH + '../data/statisticas'


def main():
  links = json.load(open(utils.LINKS_JSON_PATH, 'r'))
  for year in links:
    if utils.STATISTICS_KEY in links[year]:
      print links[year][utils.STATISTICS_KEY]
      ds.download_statisticas(links[year][utils.STATISTICS_KEY],
                             '%s/%s/' % (OUTPUT_PATH, year))
    else:
      print 'Year %s does not provide statistics info' % year


if __name__ == '__main__':
  main()
