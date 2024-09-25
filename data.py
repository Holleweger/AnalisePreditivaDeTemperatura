import pandas as pd

# Carregar o arquivo CSV original (substitua pelo caminho correto do arquivo)
file_path = 'C:\\ModeloTemp\\2023\\INMET_NE_BA_A402_BARREIRAS_01-01-2023_A_31-12-2023.CSV'
df = pd.read_csv(file_path, delimiter=';', encoding='latin1', skiprows=8)

# Renomear as colunas para remover espaços extras
df.columns = df.columns.str.strip()

# Converter a coluna 'Data' para o tipo datetime
df['Data'] = pd.to_datetime(df['Data'], errors='coerce')

# Substituir vírgulas por pontos e converter a coluna de temperatura para numérico
df['TEMPERATURA DO AR - BULBO SECO, HORARIA (°C)'] = (
    df['TEMPERATURA DO AR - BULBO SECO, HORARIA (°C)']
    .str.replace(',', '.')
    .apply(pd.to_numeric, errors='coerce')
)

# Remover as linhas onde a temperatura horária é 'nan'
df_clean = df.dropna(subset=['TEMPERATURA DO AR - BULBO SECO, HORARIA (°C)'])

# Agrupar por data e calcular a média diária de temperatura
daily_avg_temp = df_clean.groupby(df_clean['Data'].dt.date)['TEMPERATURA DO AR - BULBO SECO, HORARIA (°C)'].mean().reset_index()

# Renomear as colunas para melhor entendimento
daily_avg_temp.columns = ['Data', 'Temperatura']

# Identificar os dias que têm valores `nan` ou estão ausentes
missing_days = df['Data'].dt.date[~df['Data'].dt.date.isin(daily_avg_temp['Data'].unique())].unique()

# Substituir o ponto por vírgula nas médias
daily_avg_temp['Temperatura'] = daily_avg_temp['Temperatura'].apply(lambda x: f"{x:.2f}".replace('.', ','))

# Salvar o novo CSV com a temperatura média diária, usando o separador ";"
output_path = 'C:\\ModeloTemp\\data.CSV'  # Substitua por um caminho existente
daily_avg_temp.to_csv(output_path, sep=';', index=False, encoding='latin1')
print(f"Arquivo CSV com a temperatura média diária salvo em: {output_path}")
