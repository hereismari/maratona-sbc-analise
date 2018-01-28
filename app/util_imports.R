library(readr)
library(dplyr)

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
  
  problems = data.frame()
  for(ano in anos) {

    temp = paste(root, "estatisticas/", sep="")
    temp = paste(temp, ano, sep="")
    path = paste(temp, "/problems_pre_processado.csv", sep="")
    temp_df = read_csv(path)
    problems = rbind(problems, temp_df)
    
  }
  
  problems = problems %>%
    group_by(Problems) %>%
    summarise(Total = sum(Total),
              Accepted = sum(Accepted))
  
  
  return(problems)
  
}