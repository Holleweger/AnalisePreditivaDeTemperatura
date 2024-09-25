# Instalar pacotes necessários, se ainda não estiverem instalados
install.packages("ggplot2")
install.packages("caret")

# Carregar pacotes necessários
library(ggplot2)
library(caret)

# Ler os dados do CSV
dados <- read.csv2("C:\\dev\\ModeloTemp\\data.CSV", stringsAsFactors = FALSE)

# Converter a coluna de data para o formato Date
dados$Data <- as.Date(dados$Data)

# Extrair mês e temperatura média
dados$mes <- as.numeric(format(dados$Data, "%m"))  # Use as.numeric para garantir que é numérico
dados$temperatura <- as.numeric(gsub(",", ".", dados$Temperatura))

# Remover NAs
dados <- na.omit(dados)

# Calcular a temperatura média por mês
dados_media <- aggregate(temperatura ~ mes, data = dados, FUN = mean)

# Definir parâmetros
n <- 12  # Número de meses no ano
meses <- 1:n

# Criar o DataFrame para os meses do ano
dados_meses <- data.frame(mes = meses)

# Unir os dados mensais com a média de temperatura
dados_meses <- merge(dados_meses, dados_media, by = "mes", all.x = TRUE)

# Dividir os dados em conjuntos de treino e teste
set.seed(123)
indices <- createDataPartition(dados_meses$temperatura, p = 0.8, list = FALSE)
treino <- dados_meses[indices, ]
teste <- dados_meses[-indices, ]

# Treinar os modelos de regressão quadrática para temperatura
modelo_temp <- lm(temperatura ~ mes + I(mes^2), data = treino)

# Gerar previsões para os 12 meses do próximo ano
meses_proximo_ano <- data.frame(mes = 1:n)
previsoes_temp_proximo_ano <- predict(modelo_temp, newdata = meses_proximo_ano)

# Adicionar as previsões ao DataFrame
meses_proximo_ano$temperatura_prevista <- previsoes_temp_proximo_ano

# Gráfico de Temperatura Prevista para os 12 meses
ggplot(data = meses_proximo_ano) +
  geom_line(aes(x = mes, y = temperatura_prevista), color = "red", size = 1) +
  labs(title = "Temperaturas Previstas para os Próximos 12 Meses",
       x = "Mês do Ano",
       y = "Temperatura (°C)") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(1, n, by = 1), labels = month.name[1:n])
