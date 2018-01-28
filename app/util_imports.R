library(readr)

import_scoreboard = function(ano) {
  csv_name = paste(ano, ".csv", sep="")
  path = paste("data/scoreboards/pre_processado_", csv_name, sep="")
  
  scoreboards = read_csv(path)
  scoreboards$ano = ano
  
  return(scoreboards)
}

import_competidores = function() {
  competidores = read_csv("dados/competidores.csv")
  return(competidores)
}

import_universidades = function() {
  univs = read_csv("dados/auxiliares/universidades.csv")
  return(competidores)
}