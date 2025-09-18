-- models/monitoring/silver_quality_monitor.sql
-- Monitora a qualidade dos dados na camada Silver
-- Este modelo não bloqueia os testes, apenas reporta problemas

WITH problemas_detalhados AS (
    SELECT 
        'id_registro_null' AS tipo_problema,
        COUNT(*) AS quantidade_registros,
        'Registros sem ID único' AS descricao
    FROM COVID19.silver.int_leitos_ocupacao_unificado
    WHERE id_registro IS NULL
    
    UNION ALL
    
    SELECT 
        'ano_dados_null' AS tipo_problema,
        COUNT(*) AS quantidade_registros,
        'Registros sem ano de dados' AS descricao
    FROM COVID19.silver.int_leitos_ocupacao_unificado
    WHERE ano_dados IS NULL
    
    UNION ALL
    
    SELECT 
        'ano_dados_invalido' AS tipo_problema,
        COUNT(*) AS quantidade_registros,
        'Registros com ano fora do período válido (2020-2022)' AS descricao
    FROM COVID19.silver.int_leitos_ocupacao_unificado
    WHERE ano_dados NOT IN (2020, 2021, 2022)
    
    UNION ALL
    
    SELECT 
        'id_localidade_fallback' AS tipo_problema,
        COUNT(*) AS quantidade_registros,
        'Registros usando localidade padrão (-999)' AS descricao
    FROM COVID19.silver.int_leitos_ocupacao_unificado
    WHERE id_localidade = -999
    
    UNION ALL
    
    SELECT 
        'cnes_null' AS tipo_problema,
        COUNT(*) AS quantidade_registros,
        'Registros sem código CNES' AS descricao
    FROM COVID19.silver.int_leitos_ocupacao_unificado
    WHERE cnes IS NULL OR TRIM(cnes) = ''
),

total_registros AS (
    SELECT COUNT(*) as total
    FROM COVID19.silver.int_leitos_ocupacao_unificado
)

SELECT 
    p.tipo_problema,
    p.quantidade_registros,
    p.descricao,
    t.total as total_registros,
    ROUND((p.quantidade_registros * 100.0 / t.total), 2) as percentual,
    CURRENT_TIMESTAMP() as data_execucao
FROM problemas_detalhados p
CROSS JOIN total_registros t
WHERE p.quantidade_registros > 0  -- Mostra apenas problemas que existem
ORDER BY p.quantidade_registros DESC