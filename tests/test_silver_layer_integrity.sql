-- Teste rigoroso para camada Silver (intermediate)
-- Esta camada deve ter dados limpos e consistentes - tolerância zero para campos críticos
-- Permite id_localidade = -1 para casos não informados

SELECT 
    id_registro,
    data_notificacao,
    cnes,
    id_localidade,
    ano_dados,
    CASE 
        WHEN id_registro IS NULL THEN 'ID_REGISTRO_NULL'
        WHEN data_notificacao IS NULL THEN 'DATA_NOTIFICACAO_NULL'
        WHEN cnes IS NULL THEN 'CNES_NULL'
        WHEN TRIM(cnes) = '' THEN 'CNES_EMPTY'
        WHEN id_localidade IS NULL THEN 'ID_LOCALIDADE_NULL'  -- Agora não deve acontecer
        WHEN ano_dados IS NULL THEN 'ANO_DADOS_NULL'
        WHEN ano_dados NOT IN (2020, 2021, 2022) THEN 'ANO_DADOS_INVALID'
        ELSE 'UNKNOWN_ISSUE'
    END AS error_type
FROM {{ ref('int_leitos_ocupacao_unificado') }}
WHERE 
    id_registro IS NULL 
    OR data_notificacao IS NULL 
    OR cnes IS NULL 
    OR TRIM(cnes) = ''
    OR id_localidade IS NULL  -- Apenas NULL é problema, -1 é válido
    OR ano_dados IS NULL
    OR ano_dados NOT IN (2020, 2021, 2022)