source("app/util_imports.R")

#source("util_imports.R")

competitors = import_competitors()


# ---


pega_nome_time = function(v) {
  m_string = v[[2]]
  m_string = trimws(m_string)
  return(m_string)
}
scoreboard = import_scoreboard(2017) 
scoreboard$nome_split = strsplit(scoreboard$Name, "]")
scoreboard$User = sapply(scoreboard$nome_split, pega_nome_time)
scoreboard = scoreboard %>% filter(User %in% c('Monkeys', 'Turkeys'))
scoreboard = t(scoreboard)

submissions = import_submissions(2017) %>%
  filter(Name %in% c('Turkeys', 'fuze')) %>%
  


