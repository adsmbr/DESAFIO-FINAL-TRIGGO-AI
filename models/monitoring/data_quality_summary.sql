-- Data Quality Investigation Model
-- This can be run with: dbt run --select data_quality_summary
-- Provides immediate insights into data quality issues

{{ config(
    materialized='table',
    schema='monitoring'
) }}

WITH data_quality_results AS (
    -- Check for NULL values in key metrics
    SELECT 
        'NULL_quantidade_leitos_ocupados' AS issue_type,
        COUNT(*) AS affected_records,
        'Records with NULL bed occupancy values' AS description
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE quantidade_leitos_ocupados IS NULL

    UNION ALL

    -- Check for missing time references
    SELECT 
        'NULL_id_tempo' AS issue_type,
        COUNT(*) AS affected_records,
        'Records missing time dimension reference' AS description
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE id_tempo IS NULL

    UNION ALL

    -- Check for missing location references  
    SELECT 
        'NULL_id_localidade' AS issue_type,
        COUNT(*) AS affected_records,
        'Records missing location dimension reference' AS description
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE id_localidade IS NULL

    UNION ALL

    -- Check for negative occupancy values
    SELECT 
        'negative_occupancy' AS issue_type,
        COUNT(*) AS affected_records,
        'Records with impossible negative bed counts' AS description
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE quantidade_leitos_ocupados < 0

    UNION ALL

    -- Check for unrealistically high values
    SELECT 
        'extremely_high_occupancy' AS issue_type,
        COUNT(*) AS affected_records,
        'Records with suspiciously high bed counts (>10000)' AS description
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE quantidade_leitos_ocupados > 10000

    UNION ALL

    -- Summary statistics
    SELECT 
        'total_records' AS issue_type,
        COUNT(*) AS affected_records,
        'Total records in fact table' AS description
    FROM {{ ref('fact_ocupacao_leitos') }}

    UNION ALL

    -- Check for data freshness (records older than expected)
    SELECT 
        'outdated_records' AS issue_type,
        COUNT(*) AS affected_records,
        'Records with update timestamps older than 30 days' AS description
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE updated_at < CURRENT_DATE() - INTERVAL '30 days'

    UNION ALL

    -- Check for orphaned CNES codes
    SELECT 
        'orphaned_cnes' AS issue_type,
        COUNT(DISTINCT id_cnes) AS affected_records,
        'CNES codes in facts but not in dimension' AS description
    FROM {{ ref('fact_ocupacao_leitos') }} f
    LEFT JOIN {{ ref('dim_cnes') }} c ON f.id_cnes = c.id_cnes
    WHERE c.id_cnes IS NULL

    UNION ALL

    -- Check for missing exit data consistency
    SELECT 
        'inconsistent_exit_data' AS issue_type,
        COUNT(*) AS affected_records,
        'Records with deaths but no total exits reported' AS description
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE saida_confirmada_obitos > 0 
      AND (saida_confirmada_altas IS NULL OR saida_confirmada_altas = 0)
)

SELECT 
    issue_type,
    affected_records,
    description,
    CASE 
        WHEN affected_records = 0 THEN '✅ OK'
        WHEN affected_records < 10 THEN '⚠️ Minor Issue'
        ELSE '🚨 Attention Required'
    END AS status
FROM data_quality_results
ORDER BY 
    CASE WHEN issue_type = 'total_records' THEN 1 ELSE 0 END,
    affected_records DESC