library(readr)
library(dplyr)

root = "../dados/"
#root = "~/maratona-sbc-analise/dados/"

import_scoreboard = function(ano) {
  csv_name = paste(ano, ".csv", sep="")
  path = paste(root, "scoreboards/pre_processado_", sep="")
  path = paste(path, csv_name, sep="")
  
  scoreboards = read_csv(path)
  scoreboards$ano = ano
  
  return(scoreboards)
}

import_competitors = function() {
  path = paste(root, "pre_processado_competidores.csv", sep="")
  competitors = read_csv(path)
  return(competitors)
}

import_competitors_grouped_by_state = function() {
  competitors = import_competitors()
  
  # We don't want the competitors, we just want the team!
  # the line below removes the repetitions
  competitors <- subset(competitors, !duplicated(competitors[,2]))
  
  # group by state
  competitors_grouped <- competitors %>%
                         group_by(estado) %>%
                         summarise(classificados = sum(classificado),
                                   ouro = sum(medalha=="gold"),
                                   prata = sum(medalha=="silver"),
                                   bronze = sum(medalha=="bronze"),
                                   medalhas = n())
  
  return(competitors_grouped)
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

import_coaches = function() {
  
  path = paste(root, "pre_processado_coaches.csv", sep="")
  temp_df = read_csv(path)
  
  competitors = import_competitors()
  competitors = subset(competitors, !duplicated(competitors[,2]))

  coaches = merge(competitors, temp_df, by=c("time", "ano", "universidade"))
  
  return(coaches)
}

import_coaches_grouped = function(){
  coaches = import_coaches()
  coaches_grouped = coaches %>% group_by(coach) %>%
    summarise(ouro=sum(medalha == 'gold'), 
              prata=sum(medalha == 'silver'),
              bronze=sum(medalha == 'bronze'), 
              medalhas=n(), 
              classificados=sum(classificado == 1)) %>%
    arrange(-ouro, -prata, -bronze)
  return (coaches_grouped)
}

import_submissions = function(ano) {
  csv_name = paste(ano, ".csv", sep="")
  path = paste(root, "submissoes/pre_processado_", sep="")
  path = paste(path, csv_name, sep="")
  
  submissoes = read_csv(path)
  
  submissoes = submissoes %>% filter(Time > 0)
  
  pega_nome_time = function(v) {
    if (length(v) > 1) {
      m_string = v[[2]]
      m_string = trimws(m_string)
      return(m_string)  
    } else {
      m_string = v[[1]]
      m_string = trimws(m_string)
      return(m_string)  
    }
  }
  
  pega_univ_time = function(v) {
    if (length(v) > 1) {
      m_string = v[[1]]
      m_string = trimws(m_string)
      return(m_string)  
    } else {
      return(NA)  
    }
  }
  
  submissoes$nome_split = strsplit(submissoes$User, "]")
  submissoes$User = sapply(submissoes$nome_split, pega_nome_time)
  submissoes$Univ = sapply(submissoes$nome_split, pega_univ_time)
  submissoes$Univ = gsub("[[]", "", submissoes$Univ)
  
  return(submissoes)
}
