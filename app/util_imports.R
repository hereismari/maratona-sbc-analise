library(readr)

root = "../dados/"

import_scoreboard = function(ano) {
  csv_name = paste(ano, ".csv", sep="")
  path = paste(root, "scoreboards/pre_processado_", sep="")
  path = paste(path, csv_name, sep="")
  
  scoreboards = read_csv(path)
  scoreboards$ano = ano
  
  return(scoreboards)
}

import_competitors = function() {
  path = paste(root, "competidores.csv", sep="")
  competitors = read_csv(path)
  return(competitors)
}

import_universities = function() {
  path = paste(root, "auxiliares/universidades.csv", sep="")
  univs = read_csv(path)
  return(univs)
}

import_problems = function(anos) {
  if (length(anos) == 1) {
    temp = paste(root, "estatisticas/", sep="")
    temp = paste(temp, ano, sep="")
    path = paste(temp, "/problems_pre_processado.csv", sep="")
    problems = read_csv(path)
    return(problems)
  } else {
    
  }

}