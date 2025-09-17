-- models/monitoring/data_quality_dashboard_enhanced.sql
-- Enhanced data quality monitoring dashboard
-- Provides comprehensive quality metrics for all layers

{{ config(
    materialized='table',
    schema='monitoring'
) }}

WITH fact_quality AS (
    SELECT 
        'fact_ocupacao_leitos' as table_name,
        'gold' as layer,
        COUNT(*) as total_records,
        
        -- Completeness metrics
        COUNT(CASE WHEN id_fato IS NULL THEN 1 END) as null_primary_keys,
        COUNT(CASE WHEN quantidade_leitos_ocupados IS NULL THEN 1 END) as null_metrics,
        COUNT(CASE WHEN id_tempo IS NULL THEN 1 END) as null_time_keys,
        COUNT(CASE WHEN id_localidade IS NULL THEN 1 END) as null_location_keys,
        
        -- Validity metrics
        COUNT(CASE WHEN quantidade_leitos_ocupados < 0 THEN 1 END) as negative_values,
        COUNT(CASE WHEN quantidade_leitos_ocupados > 10000 THEN 1 END) as extreme_values,
        
        -- Freshness metrics
        MAX(updated_at) as last_update,
        DATEDIFF('hour', MAX(updated_at), CURRENT_TIMESTAMP()) as hours_since_update,
        
        -- Consistency metrics
        COUNT(DISTINCT id_fato) as unique_facts,
        
        CURRENT_TIMESTAMP() as measured_at
    FROM {{ ref('fact_ocupacao_leitos') }}
),

staging_quality AS (
    SELECT 
        'stg_leito_ocupacao_consolidado' as table_name,
        'bronze' as layer,
        COUNT(*) as total_records,
        
        -- Completeness metrics
        COUNT(CASE WHEN id_registro IS NULL THEN 1 END) as null_primary_keys,
        COUNT(CASE WHEN data_notificacao IS NULL THEN 1 END) as null_dates,
        COUNT(CASE WHEN cnes IS NULL OR cnes = '' THEN 1 END) as null_cnes,
        COUNT(CASE WHEN estado IS NULL OR estado = '' THEN 1 END) as null_states,
        
        -- Validity metrics
        COUNT(CASE WHEN ocupacao_covid_cli < 0 OR ocupacao_covid_uti < 0 THEN 1 END) as negative_values,
        COUNT(CASE WHEN data_notificacao > CURRENT_DATE THEN 1 END) as future_dates,
        
        -- Freshness metrics
        MAX(updated_at) as last_update,
        DATEDIFF('hour', MAX(updated_at), CURRENT_TIMESTAMP()) as hours_since_update,
        
        -- Year distribution
        COUNT(DISTINCT ano_dados) as unique_years,
        
        CURRENT_TIMESTAMP() as measured_at
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
),

dimension_quality AS (
    -- Combine dimension quality metrics
    SELECT 
        'dim_tempo' as table_name,
        'gold' as layer,
        COUNT(*) as total_records,
        COUNT(CASE WHEN id_tempo IS NULL THEN 1 END) as null_primary_keys,
        COUNT(CASE WHEN data IS NULL THEN 1 END) as null_dates,
        0 as data_issues,  -- Dimensions typically don't have data quality issues
        0 as validity_issues,
        NULL::timestamp as last_update,
        NULL as hours_since_update,
        COUNT(DISTINCT EXTRACT(YEAR FROM data)) as unique_years,
        CURRENT_TIMESTAMP() as measured_at
    FROM {{ ref('dim_tempo') }}
    
    UNION ALL
    
    SELECT 
        'dim_localidade' as table_name,
        'gold' as layer,
        COUNT(*) as total_records,
        COUNT(CASE WHEN id_localidade IS NULL THEN 1 END) as null_primary_keys,
        COUNT(CASE WHEN estado IS NULL OR municipio IS NULL THEN 1 END) as null_locations,
        0 as data_issues,
        0 as validity_issues,
        NULL::timestamp as last_update,
        NULL as hours_since_update,
        COUNT(DISTINCT estado) as unique_states,
        CURRENT_TIMESTAMP() as measured_at
    FROM {{ ref('dim_localidade') }}
)

-- Final quality dashboard
SELECT 
    table_name,
    layer,
    total_records,
    
    -- Quality scores (0-100)
    CASE 
        WHEN total_records = 0 THEN 0
        ELSE ROUND(100.0 * (total_records - null_primary_keys) / total_records, 2)
    END as completeness_score,
    
    CASE 
        WHEN layer = 'bronze' THEN
            CASE 
                WHEN total_records = 0 THEN 0
                ELSE GREATEST(0, ROUND(100.0 * (total_records - negative_values - future_dates) / total_records, 2))
            END
        WHEN layer = 'gold' THEN
            CASE 
                WHEN total_records = 0 THEN 0
                ELSE GREATEST(0, ROUND(100.0 * (total_records - negative_values - extreme_values) / total_records, 2))
            END
        ELSE 100
    END as validity_score,
    
    CASE 
        WHEN hours_since_update IS NULL THEN 100  -- Static dimensions
        WHEN hours_since_update <= 24 THEN 100
        WHEN hours_since_update <= 48 THEN 80
        WHEN hours_since_update <= 72 THEN 60
        ELSE 40
    END as freshness_score,
    
    -- Overall quality score (weighted average)
    ROUND(
        (completeness_score * 0.4 + 
         validity_score * 0.4 + 
         freshness_score * 0.2), 2
    ) as overall_quality_score,
    
    -- Quality status
    CASE 
        WHEN ROUND(
            (completeness_score * 0.4 + 
             validity_score * 0.4 + 
             freshness_score * 0.2), 2
        ) >= 95 THEN '✅ EXCELLENT'
        WHEN ROUND(
            (completeness_score * 0.4 + 
             validity_score * 0.4 + 
             freshness_score * 0.2), 2
        ) >= 85 THEN '🟢 GOOD'
        WHEN ROUND(
            (completeness_score * 0.4 + 
             validity_score * 0.4 + 
             freshness_score * 0.2), 2
        ) >= 70 THEN '🟡 NEEDS ATTENTION'
        ELSE '🔴 CRITICAL'
    END as quality_status,
    
    -- Detailed metrics
    null_primary_keys,
    COALESCE(null_metrics, null_dates) as null_important_fields,
    COALESCE(negative_values, 0) as data_validity_issues,
    COALESCE(extreme_values, future_dates, 0) as extreme_anomalies,
    
    hours_since_update,
    last_update,
    measured_at,
    
    -- Recommendations
    CASE 
        WHEN null_primary_keys > 0 THEN 'Check primary key generation logic'
        WHEN COALESCE(negative_values, 0) > total_records * 0.01 THEN 'Investigate negative values in source data'
        WHEN hours_since_update > 48 THEN 'Data pipeline may be stalled'
        WHEN overall_quality_score < 85 THEN 'Multiple quality issues detected'
        ELSE 'Data quality is within acceptable limits'
    END as recommendation

FROM (
    SELECT 
        table_name, layer, total_records, null_primary_keys,
        null_metrics, null_time_keys as null_dates, 
        negative_values, extreme_values as future_dates,
        last_update, hours_since_update, measured_at,
        extreme_values
    FROM fact_quality
    
    UNION ALL
    
    SELECT 
        table_name, layer, total_records, null_primary_keys,
        null_dates as null_metrics, null_cnes as null_dates,
        negative_values, future_dates, 
        last_update, hours_since_update, measured_at,
        0 as extreme_values
    FROM staging_quality
    
    UNION ALL
    
    SELECT 
        table_name, layer, total_records, null_primary_keys,
        null_dates as null_metrics, data_issues as null_dates,
        validity_issues as negative_values, 0 as future_dates,
        last_update, hours_since_update, measured_at,
        0 as extreme_values
    FROM dimension_quality
) combined

ORDER BY 
    CASE layer 
        WHEN 'bronze' THEN 1 
        WHEN 'silver' THEN 2 
        WHEN 'gold' THEN 3 
    END,
    overall_quality_score DESC