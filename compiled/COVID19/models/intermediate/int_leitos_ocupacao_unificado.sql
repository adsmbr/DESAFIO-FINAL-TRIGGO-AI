-- models/intermediate/int_leitos_ocupacao_unificado.sql
-- Este modelo serve como ponte, enriquecendo os dados de staging com
-- as chaves das dimensões antes de carregar a tabela de fatos.
-- Inclui estratégia robusta para lidar com localidades não encontradas

WITH staging_data AS (
    SELECT * FROM COVID19.bronze.stg_leito_ocupacao_consolidado
),

dim_localidade AS (
    SELECT * FROM COVID19.gold.dim_localidade
)

SELECT
    stg.*,  -- Seleciona todas as colunas originais do staging
    COALESCE(loc.id_localidade, -999) AS id_localidade -- Usa -999 como fallback padrão

FROM staging_data stg

-- Faz o JOIN com a dimensão de localidade usando estratégia mais robusta
LEFT JOIN dim_localidade loc ON (
    -- Estratégia 1: Match exato com campos preferenciais
    (UPPER(TRIM(COALESCE(stg.municipio_notificacao, ''))) = UPPER(TRIM(COALESCE(loc.municipio, '')))
     AND UPPER(TRIM(COALESCE(stg.estado_notificacao, ''))) = UPPER(TRIM(COALESCE(loc.estado, ''))))
    OR
    -- Estratégia 2: Match com campos alternativos
    (UPPER(TRIM(COALESCE(stg.municipio, ''))) = UPPER(TRIM(COALESCE(loc.municipio, '')))
     AND UPPER(TRIM(COALESCE(stg.estado, ''))) = UPPER(TRIM(COALESCE(loc.estado, ''))))
    OR
    -- Estratégia 3: Match com 'DESCONHECIDO' se ambos são nulos/vazios
    (TRIM(COALESCE(stg.municipio_notificacao, stg.municipio, '')) = ''
     AND TRIM(COALESCE(stg.estado_notificacao, stg.estado, '')) = ''
     AND loc.municipio = 'DESCONHECIDO')
)