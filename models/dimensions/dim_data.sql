-- models/dimensions/dim_data.sql
-- Dimensão de data simplificada para compatibilidade com fact table
WITH datas_distintas AS (
    -- Pega todas as datas únicas dos dados de leitos consolidados
    SELECT DISTINCT CAST(data_notificacao AS DATE) AS data
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    WHERE data_notificacao IS NOT NULL
)
SELECT
    -- Cria um ID numérico para a data (ex: 20210131)
    TO_CHAR(data, 'YYYYMMDD')::INT AS id_tempo,
    data,
    EXTRACT(YEAR FROM data) AS ano,
    EXTRACT(MONTH FROM data) AS mes,
    EXTRACT(DAY FROM data) AS dia,
    EXTRACT(DAYOFWEEK FROM data) AS dia_da_semana,
    EXTRACT(QUARTER FROM data) AS trimestre,
    EXTRACT(WEEK FROM data) AS semana_do_ano
FROM datas_distintas
ORDER BY data