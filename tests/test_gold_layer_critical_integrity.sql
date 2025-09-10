-- Teste crítico para camada Gold (facts)
-- Tolerância zero para problemas na camada de consumo final

SELECT 
    id_fato,
    id_tempo,
    id_localidade,
    id_cnes,
    quantidade_leitos_ocupados,
    'Critical integrity violation in Gold layer' AS error_message
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE 
    id_fato IS NULL 
    OR id_tempo IS NULL 
    OR id_localidade IS NULL 
    OR id_cnes IS NULL 
    OR quantidade_leitos_ocupados IS NULL
    OR quantidade_leitos_ocupados < 0  -- Valores negativos são impossíveis