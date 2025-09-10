-- Teste de integridade para dados consolidados (staging)
-- Permite alguns problemas menores mas detecta falhas críticas
-- Para problemas críticos: >5% dos registros com falhas ou campos essenciais nulos

WITH problemas_criticos AS (
    SELECT COUNT(*) as registros_problematicos
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    WHERE 
        id_registro IS NULL  -- ID é fundamental
        OR ano_dados IS NULL  -- Ano é fundamental para particionamento
        OR ano_dados NOT IN (2020, 2021, 2022)  -- Anos válidos apenas
),
total_registros AS (
    SELECT COUNT(*) as total
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
)
-- Falha apenas se mais de 5% dos registros tiverem problemas CRÍTICOS
SELECT 
    p.registros_problematicos,
    t.total,
    ROUND((p.registros_problematicos * 100.0 / t.total), 2) as percentual_problemas
FROM problemas_criticos p, total_registros t
WHERE (p.registros_problematicos * 100.0 / t.total) > 5.0  -- Falha se >5% problemático