-- models/monitoring/performance_baseline.sql
-- Performance baseline monitoring for COVID19 pipeline
-- This model tracks performance metrics without affecting the main pipeline

{{ config(
    materialized='table',
    schema='monitoring'
) }}

-- Track performance metrics for all main models
WITH fact_metrics AS (
    SELECT 
        'fact_ocupacao_leitos' as model_name,
        COUNT(*) as total_records,
        COUNT(DISTINCT id_localidade) as unique_locations,
        COUNT(DISTINCT id_tempo) as unique_dates,
        MIN(updated_at) as oldest_record,
        MAX(updated_at) as newest_record,
        AVG(quantidade_leitos_ocupados) as avg_ocupacao,
        CURRENT_TIMESTAMP() as measured_at,
        'production' as environment
    FROM {{ ref('fact_ocupacao_leitos') }}
),

dim_metrics AS (
    -- Dimension metrics
    SELECT 
        'dim_tempo' as model_name,
        COUNT(*) as total_records,
        NULL as unique_locations,
        COUNT(DISTINCT EXTRACT(YEAR FROM data)) as unique_years,
        MIN(data) as oldest_record,
        MAX(data) as newest_record,
        NULL as avg_ocupacao,
        CURRENT_TIMESTAMP() as measured_at,
        'production' as environment
    FROM {{ ref('dim_tempo') }}
    
    UNION ALL
    
    SELECT 
        'dim_localidade' as model_name,
        COUNT(*) as total_records,
        COUNT(DISTINCT estado) as unique_states,
        COUNT(DISTINCT municipio) as unique_cities,
        NULL as oldest_record,
        NULL as newest_record,
        NULL as avg_ocupacao,
        CURRENT_TIMESTAMP() as measured_at,
        'production' as environment
    FROM {{ ref('dim_localidade') }}
),

staging_metrics AS (
    -- Staging metrics
    SELECT 
        'stg_leito_ocupacao_consolidado' as model_name,
        COUNT(*) as total_records,
        COUNT(DISTINCT cnes) as unique_cnes,
        COUNT(DISTINCT ano_dados) as unique_years,
        MIN(data_notificacao) as oldest_record,
        MAX(data_notificacao) as newest_record,
        AVG(ocupacao_covid_cli + ocupacao_covid_uti) as avg_ocupacao,
        CURRENT_TIMESTAMP() as measured_at,
        'production' as environment
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
)

-- Combine all metrics
SELECT 
    model_name,
    total_records,
    unique_locations,
    unique_dates,
    oldest_record,
    newest_record,
    avg_ocupacao,
    measured_at,
    environment,
    -- Performance indicators
    CASE 
        WHEN total_records > 1000000 THEN 'HIGH_VOLUME'
        WHEN total_records > 100000 THEN 'MEDIUM_VOLUME'
        ELSE 'LOW_VOLUME'
    END as volume_category,
    
    -- Data freshness indicator
    DATEDIFF('hour', newest_record::timestamp, CURRENT_TIMESTAMP()) as hours_since_update,
    
    CASE 
        WHEN DATEDIFF('hour', newest_record::timestamp, CURRENT_TIMESTAMP()) <= 24 THEN 'FRESH'
        WHEN DATEDIFF('hour', newest_record::timestamp, CURRENT_TIMESTAMP()) <= 72 THEN 'STALE'
        ELSE 'OLD'
    END as freshness_status
    
FROM fact_metrics

UNION ALL

SELECT 
    model_name,
    total_records,
    unique_locations,
    unique_dates,
    oldest_record,
    newest_record,
    avg_ocupacao,
    measured_at,
    environment,
    CASE 
        WHEN total_records > 10000 THEN 'HIGH_VOLUME'
        WHEN total_records > 1000 THEN 'MEDIUM_VOLUME'
        ELSE 'LOW_VOLUME'
    END as volume_category,
    NULL as hours_since_update,
    'STATIC' as freshness_status
FROM dim_metrics

UNION ALL

SELECT 
    model_name,
    total_records,
    unique_locations as unique_cnes,
    unique_dates as unique_years,
    oldest_record,
    newest_record,
    avg_ocupacao,
    measured_at,
    environment,
    CASE 
        WHEN total_records > 2000000 THEN 'HIGH_VOLUME'
        WHEN total_records > 500000 THEN 'MEDIUM_VOLUME'
        ELSE 'LOW_VOLUME'
    END as volume_category,
    DATEDIFF('hour', newest_record::timestamp, CURRENT_TIMESTAMP()) as hours_since_update,
    CASE 
        WHEN DATEDIFF('hour', newest_record::timestamp, CURRENT_TIMESTAMP()) <= 24 THEN 'FRESH'
        WHEN DATEDIFF('hour', newest_record::timestamp, CURRENT_TIMESTAMP()) <= 72 THEN 'STALE'
        ELSE 'OLD'
    END as freshness_status
FROM staging_metrics

ORDER BY model_name