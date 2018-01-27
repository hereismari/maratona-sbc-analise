# coding: utf8
import utils
import download_submissoes as ds
import json

OUTPUT_PATH = utils.OUTPUT_PATH + 'submissoes'


def main():
  links = json.load(open(utils.LINKS_JSON_PATH, 'r'))
  for year in links:
    if utils.SUBMISSOES_KEY in links[year]:
      ds.download_submissoes(links[year][utils.SUBMISSOES_KEY], '%s/%s.csv' % (OUTPUT_PATH, year))
    else:
      print 'Year %s does not provide runs information' % year


if __name__ == '__main__':
  main()
