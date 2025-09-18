-- Modelo de investigação para problemas na camada Silver
-- Este modelo ajuda a identificar por que registros não conseguem fazer JOIN com dimensões



WITH silver_problems AS (
    SELECT 
        id_registro,
        data_notificacao,
        cnes,
        id_localidade,
        ano_dados,
        municipio_notificacao,
        estado_notificacao,
        municipio,
        estado,
        CASE 
            WHEN id_registro IS NULL THEN 'ID_REGISTRO_NULL'
            WHEN data_notificacao IS NULL THEN 'DATA_NOTIFICACAO_NULL'
            WHEN cnes IS NULL THEN 'CNES_NULL'
            WHEN TRIM(cnes) = '' THEN 'CNES_EMPTY'
            WHEN id_localidade IS NULL THEN 'ID_LOCALIDADE_NULL'
            WHEN ano_dados IS NULL THEN 'ANO_DADOS_NULL'
            WHEN ano_dados NOT IN (2020, 2021, 2022) THEN 'ANO_DADOS_INVALID'
            ELSE 'UNKNOWN_ISSUE'
        END AS problem_type
    FROM COVID19.silver.int_leitos_ocupacao_unificado
    WHERE 
        id_registro IS NULL 
        OR data_notificacao IS NULL 
        OR cnes IS NULL 
        OR TRIM(cnes) = ''
        OR id_localidade IS NULL
        OR ano_dados IS NULL
        OR ano_dados NOT IN (2020, 2021, 2022)
),

problem_summary AS (
    SELECT 
        problem_type,
        COUNT(*) AS affected_records,
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM COVID19.silver.int_leitos_ocupacao_unificado) AS percentage_affected
    FROM silver_problems
    GROUP BY problem_type
),

-- Análise específica para problemas de localidade (provável causa principal)
locality_analysis AS (
    SELECT 
        'LOCALITY_MISMATCH_ANALYSIS' as analysis_type,
        COUNT(*) as total_unmatched,
        COUNT(DISTINCT COALESCE(municipio_notificacao, municipio)) as unique_municipios,
        COUNT(DISTINCT COALESCE(estado_notificacao, estado)) as unique_estados
    FROM COVID19.silver.int_leitos_ocupacao_unificado
    WHERE id_localidade IS NULL
)

-- Resultado final combinado
SELECT 
    'SILVER_LAYER_ISSUE' as check_type,
    problem_type,
    affected_records,
    ROUND(percentage_affected, 2) as percentage_affected,
    CASE 
        WHEN affected_records = 0 THEN '✅ OK'
        WHEN percentage_affected < 1.0 THEN '⚠️ Atenção Menor'
        WHEN percentage_affected < 5.0 THEN '⚠️ Atenção Moderada'
        ELSE '🚨 Problema Crítico'
    END AS status,
    CURRENT_TIMESTAMP() as checked_at
FROM problem_summary

UNION ALL

SELECT 
    'LOCALITY_ANALYSIS' as check_type,
    analysis_type as problem_type,
    total_unmatched as affected_records,
    ROUND(total_unmatched * 100.0 / (SELECT COUNT(*) FROM COVID19.silver.int_leitos_ocupacao_unificado), 2) as percentage_affected,
    CASE 
        WHEN total_unmatched = 0 THEN '✅ Todos Localizados'
        WHEN total_unmatched < 50 THEN '⚠️ Poucos Não Localizados'
        ELSE '🚨 Muitos Não Localizados'
    END AS status,
    CURRENT_TIMESTAMP() as checked_at
FROM locality_analysis

ORDER BY affected_records DESC