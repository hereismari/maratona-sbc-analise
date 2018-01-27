# coding: utf8
import utils
import download_scoreboard as ds
import json

OUTPUT_PATH = utils.OUTPUT_PATH + 'scoreboards'


def main():
  links = json.load(open(utils.LINKS_JSON_PATH, 'r'))
  for year in links:
    if not utils.COMMENT_SCOREBOARD_KEY in links[year]:
      ds.download_scoreboard(links[year][utils.SCOREBOARD_KEY],
                             '%s/%s.csv' % (OUTPUT_PATH, year))
    else:
      print 'Ignoring %s, reason: %s' % (year,
                                         links[year][utils.COMMENT_SCOREBOARD_KEY])


if __name__ == '__main__':
  main()
