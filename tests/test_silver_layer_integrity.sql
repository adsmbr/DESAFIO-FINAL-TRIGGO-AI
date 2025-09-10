-- Teste rigoroso para camada Silver (intermediate)
-- Esta camada deve ter dados limpos e consistentes - tolerância zero para campos críticos

SELECT 
    id_registro,
    data_notificacao,
    cnes,
    id_localidade,
    'Critical field missing in Silver layer' AS error_message
FROM {{ ref('int_leitos_ocupacao_unificado') }}
WHERE 
    id_registro IS NULL 
    OR data_notificacao IS NULL 
    OR cnes IS NULL 
    OR TRIM(cnes) = ''
    OR ano_dados IS NULL
    OR ano_dados NOT IN (2020, 2021, 2022)