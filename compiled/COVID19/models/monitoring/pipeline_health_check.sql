-- models/monitoring/pipeline_health_check.sql
-- Pipeline health monitoring - tracks overall health of the dbt pipeline
-- This model provides operational insights without affecting the main pipeline



WITH model_health AS (
    -- Check health of each model layer
    SELECT 
        'staging' as layer,
        'stg_leito_ocupacao_consolidado' as model_name,
        COUNT(*) as record_count,
        COUNT(DISTINCT ano_dados) as data_completeness_indicator,
        MAX(updated_at) as last_updated,
        CURRENT_TIMESTAMP() as checked_at
    FROM COVID19.bronze.stg_leito_ocupacao_consolidado
    
    UNION ALL
    
    SELECT 
        'intermediate' as layer,
        'int_leitos_ocupacao_unificado' as model_name,
        COUNT(*) as record_count,
        COUNT(DISTINCT id_localidade) as data_completeness_indicator,
        MAX(updated_at) as last_updated,
        CURRENT_TIMESTAMP() as checked_at
    FROM COVID19.silver.int_leitos_ocupacao_unificado
    
    UNION ALL
    
    SELECT 
        'facts' as layer,
        'fact_ocupacao_leitos' as model_name,
        COUNT(*) as record_count,
        COUNT(DISTINCT id_tempo) as data_completeness_indicator,
        MAX(updated_at) as last_updated,
        CURRENT_TIMESTAMP() as checked_at
    FROM COVID19.gold.fact_ocupacao_leitos
    
    UNION ALL
    
    SELECT 
        'dimensions' as layer,
        'dim_tempo' as model_name,
        COUNT(*) as record_count,
        COUNT(DISTINCT EXTRACT(YEAR FROM data)) as data_completeness_indicator,
        NULL as last_updated,
        CURRENT_TIMESTAMP() as checked_at
    FROM COVID19.gold.dim_tempo
    
    UNION ALL
    
    SELECT 
        'dimensions' as layer,
        'dim_localidade' as model_name,
        COUNT(*) as record_count,
        COUNT(DISTINCT estado) as data_completeness_indicator,
        NULL as last_updated,
        CURRENT_TIMESTAMP() as checked_at
    FROM COVID19.gold.dim_localidade
),

health_assessment AS (
    SELECT 
        layer,
        model_name,
        record_count,
        data_completeness_indicator,
        last_updated,
        checked_at,
        
        -- Health indicators
        CASE 
            WHEN record_count = 0 THEN 'CRITICAL'
            WHEN layer = 'staging' AND record_count < 500000 THEN 'WARNING'
            WHEN layer = 'intermediate' AND record_count < 500000 THEN 'WARNING'
            WHEN layer = 'facts' AND record_count < 1000000 THEN 'WARNING'
            WHEN layer = 'dimensions' AND record_count < 100 THEN 'WARNING'
            ELSE 'HEALTHY'
        END as volume_health,
        
        CASE 
            WHEN last_updated IS NULL THEN 'STATIC'  -- Dimensions are static
            WHEN DATEDIFF('hour', last_updated, CURRENT_TIMESTAMP()) <= 24 THEN 'FRESH'
            WHEN DATEDIFF('hour', last_updated, CURRENT_TIMESTAMP()) <= 48 THEN 'STALE'
            ELSE 'OUTDATED'
        END as freshness_health,
        
        CASE 
            WHEN layer = 'staging' AND data_completeness_indicator < 3 THEN 'INCOMPLETE'  -- Should have 2020, 2021, 2022
            WHEN layer = 'intermediate' AND data_completeness_indicator < 400 THEN 'INCOMPLETE'  -- Should have many locations
            WHEN layer = 'facts' AND data_completeness_indicator < 365 THEN 'INCOMPLETE'  -- Should have daily data
            WHEN layer = 'dimensions' AND model_name = 'dim_tempo' AND data_completeness_indicator < 3 THEN 'INCOMPLETE'
            WHEN layer = 'dimensions' AND model_name = 'dim_localidade' AND data_completeness_indicator < 20 THEN 'INCOMPLETE'
            ELSE 'COMPLETE'
        END as completeness_health
    FROM model_health
),

overall_health AS (
    SELECT 
        COUNT(*) as total_models,
        COUNT(CASE WHEN volume_health = 'HEALTHY' THEN 1 END) as healthy_volume_count,
        COUNT(CASE WHEN freshness_health IN ('FRESH', 'STATIC') THEN 1 END) as healthy_freshness_count,
        COUNT(CASE WHEN completeness_health = 'COMPLETE' THEN 1 END) as healthy_completeness_count,
        
        -- Critical issues
        COUNT(CASE WHEN volume_health = 'CRITICAL' THEN 1 END) as critical_issues,
        COUNT(CASE WHEN freshness_health = 'OUTDATED' THEN 1 END) as freshness_issues,
        COUNT(CASE WHEN completeness_health = 'INCOMPLETE' THEN 1 END) as completeness_issues
    FROM health_assessment
)

-- Final health report
SELECT 
    -- Individual model health
    ha.layer,
    ha.model_name,
    ha.record_count,
    ha.data_completeness_indicator,
    ha.volume_health,
    ha.freshness_health,
    ha.completeness_health,
    
    -- Overall health score (0-100)
    ROUND(
        CASE 
            WHEN ha.volume_health = 'CRITICAL' THEN 0
            WHEN ha.volume_health = 'WARNING' THEN 60
            ELSE 80
        END +
        CASE 
            WHEN ha.freshness_health = 'OUTDATED' THEN 0
            WHEN ha.freshness_health = 'STALE' THEN 10
            ELSE 20
        END +
        CASE 
            WHEN ha.completeness_health = 'INCOMPLETE' THEN 0
            ELSE 20  -- No bonus for completeness
        END
    ) as health_score,
    
    -- Health status
    CASE 
        WHEN ha.volume_health = 'CRITICAL' OR ha.completeness_health = 'INCOMPLETE' THEN '🔴 CRITICAL'
        WHEN ha.volume_health = 'WARNING' OR ha.freshness_health = 'OUTDATED' THEN '🟡 WARNING'
        WHEN ha.freshness_health = 'STALE' THEN '🟢 MINOR_ISSUES'
        ELSE '✅ HEALTHY'
    END as health_status,
    
    -- Recommendations
    CASE 
        WHEN ha.volume_health = 'CRITICAL' THEN 'URGENT: Model has no data - check pipeline'
        WHEN ha.volume_health = 'WARNING' THEN 'Check if data volume is lower than expected'
        WHEN ha.freshness_health = 'OUTDATED' THEN 'Data is stale - check ETL process'
        WHEN ha.completeness_health = 'INCOMPLETE' THEN 'Data appears incomplete - verify sources'
        ELSE 'Model is healthy'
    END as recommendation,
    
    ha.last_updated,
    ha.checked_at,
    
    -- Global health metrics (same for all rows for easy dashboard creation)
    oh.total_models,
    oh.critical_issues,
    oh.freshness_issues,
    oh.completeness_issues,
    
    -- Overall pipeline health percentage
    ROUND(
        100.0 * (oh.total_models - oh.critical_issues - oh.freshness_issues - oh.completeness_issues) / 
        NULLIF(oh.total_models, 0), 2
    ) as pipeline_health_percentage,
    
    -- Pipeline status
    CASE 
        WHEN oh.critical_issues > 0 THEN '🔴 PIPELINE_CRITICAL'
        WHEN oh.freshness_issues > oh.total_models * 0.3 THEN '🟡 PIPELINE_WARNING'
        WHEN oh.completeness_issues > 0 THEN '🟢 PIPELINE_MINOR_ISSUES'
        ELSE '✅ PIPELINE_HEALTHY'
    END as pipeline_status

FROM health_assessment ha
CROSS JOIN overall_health oh

ORDER BY 
    CASE ha.layer 
        WHEN 'staging' THEN 1
        WHEN 'intermediate' THEN 2
        WHEN 'facts' THEN 3
        WHEN 'dimensions' THEN 4
    END,
    ha.health_score ASC  -- Show problematic models first