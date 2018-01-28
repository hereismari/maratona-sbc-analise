source("maratona-sbc-analise/app/util_imports.R")
library(rio)

# Importando shapefile (mapa do Brasil)----
shp <- readOGR("maratona-sbc-analise/app/mapa/", "BRUFE250GC_SIR", stringsAsFactors=FALSE, encoding="UTF-8")

# Importando competidores
competitors_data <- import_competitors_grouped_by_state()

# Importanto dados do IBGE utilizado para a geração de mapas
# mais detalhes em: https://dataficacao.wordpress.com/2017/02/21/criando-mapa-brasil-r/
ibge <- read.csv("maratona-sbc-analise/app/mapa/estadosibge.csv", header=T,sep=",", fileEncoding="latin1")

# Merge dos dados dos competidores com os dados do IBGE
merge_data <- merge(competitors_data, ibge, by.x = "estado", by.y = "UF", all=TRUE)

# NA -> 0
merge_data[is.na(merge_data)] <- 0

# Merge com o shapefile (mapa)
final_data <- merge(shp, merge_data, by.x = "CD_GEOCUF", by.y = "Código.UF")

# Salvar arquivo
saveRDS(final_data, file="maratona-sbc-analise/app/mapa/mapa_competidores.rds")