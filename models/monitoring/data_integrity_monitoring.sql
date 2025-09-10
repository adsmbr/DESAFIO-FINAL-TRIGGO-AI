-- Modelo de monitoramento para investigar problemas de integridade de dados
-- Este modelo é executado com 'dbt run' e fornece visibilidade sobre problemas
-- sem bloquear o pipeline de produção

{{ config(
    materialized='table',
    schema='monitoring'
) }}

WITH problemas_identificados AS (
    SELECT 
        id_registro,
        data_notificacao,
        cnes,
        ano_dados,
        CASE 
            WHEN id_registro IS NULL THEN 'ID_REGISTRO_NULL'
            WHEN data_notificacao IS NULL THEN 'DATA_NOTIFICACAO_NULL'
            WHEN cnes IS NULL THEN 'CNES_NULL'
            WHEN TRIM(cnes) = '' THEN 'CNES_EMPTY'
            WHEN ano_dados IS NULL THEN 'ANO_DADOS_NULL'
            WHEN ano_dados NOT IN (2020, 2021, 2022) THEN 'ANO_DADOS_INVALID'
            ELSE 'UNKNOWN_ISSUE'
        END AS error_type,
        CURRENT_TIMESTAMP() AS check_timestamp
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    WHERE 
        id_registro IS NULL 
        OR data_notificacao IS NULL 
        OR cnes IS NULL 
        OR TRIM(cnes) = ''
        OR ano_dados IS NULL
        OR ano_dados NOT IN (2020, 2021, 2022)
),

resumo_problemas AS (
    SELECT 
        error_type,
        COUNT(*) AS total_registros,
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM {{ ref('stg_leito_ocupacao_consolidado') }}) AS percentual_afetado
    FROM problemas_identificados
    GROUP BY error_type
)

SELECT 
    'DATA_INTEGRITY_ISSUES' AS check_type,
    error_type,
    total_registros,
    ROUND(percentual_afetado, 2) AS percentual_afetado,
    CASE 
        WHEN total_registros = 0 THEN '✅ OK'
        WHEN total_registros < 10 THEN '⚠️ Atenção Menor'
        ELSE '🚨 Ação Requerida'
    END AS status_visual,
    CURRENT_TIMESTAMP() AS verificado_em
FROM resumo_problemas

UNION ALL

-- Adiciona linha de resumo total
SELECT 
    'DATA_INTEGRITY_TOTAL' AS check_type,
    'TOTAL_ISSUES' AS error_type,
    SUM(total_registros) AS total_registros,
    ROUND(SUM(total_registros) * 100.0 / (SELECT COUNT(*) FROM {{ ref('stg_leito_ocupacao_consolidado') }}), 2) AS percentual_afetado,
    CASE 
        WHEN SUM(total_registros) = 0 THEN '✅ Dados Íntegros'
        WHEN SUM(total_registros) < 50 THEN '⚠️ Problemas Menores'
        ELSE '🚨 Problemas Críticos'
    END AS status_visual,
    CURRENT_TIMESTAMP() AS verificado_em
FROM resumo_problemas

ORDER BY total_registros DESC