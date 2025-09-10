-- Teste para validar a integridade dos dados consolidados
-- Verifica se todos os registros têm os campos essenciais preenchidos

SELECT 
    id_registro,
    data_notificacao,
    cnes,
    ano_dados,
    'Missing essential data' AS error_message
FROM {{ ref('stg_leito_ocupacao_consolidado') }}
WHERE 
    id_registro IS NULL 
    OR data_notificacao IS NULL 
    OR cnes IS NULL 
    OR TRIM(cnes) = ''
    OR ano_dados IS NULL
    OR ano_dados NOT IN (2020, 2021, 2022)