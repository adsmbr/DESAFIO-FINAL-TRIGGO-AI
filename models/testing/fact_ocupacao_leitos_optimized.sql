-- models/testing/fact_ocupacao_leitos_optimized.sql
-- TESTING VERSION of fact_ocupacao_leitos with performance optimizations
-- This model is for TESTING ONLY and does not affect the main pipeline
-- It allows us to test optimizations safely before applying to production

{{ config(
    materialized='table',  -- Start as table for initial testing
    schema='testing',       -- Isolated schema for testing
    tags=['testing', 'performance'],
    meta={
        'purpose': 'Performance testing version of fact_ocupacao_leitos',
        'status': 'testing',
        'safe_to_modify': true
    }
) }}

-- Use the performance optimization macros (optional)
-- {{ log_performance_metrics(this.name) }}

-- Exact same logic as the original fact model but in testing schema
WITH intermediate_data AS (
    SELECT 
        *
    FROM {{ ref('int_leitos_ocupacao_unificado') }}
    
    -- Optional: Add performance optimization filter for testing
    {% if var('test_date_filter', false) %}
    WHERE data_notificacao >= CURRENT_DATE - {{ var('test_days_back', 30) }}
    {% endif %}
),

-- Same unpivot logic as original
unpivoted_data AS (
    -- COVID occupancy
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 
           'COVID' AS tipo_ocupacao, 'Clínico' AS tipo_leito, 
           ocupacao_covid_cli AS ocupacao 
    FROM intermediate_data
    
    UNION ALL
    
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 
           'COVID' AS tipo_ocupacao, 'UTI' AS tipo_leito, 
           ocupacao_covid_uti AS ocupacao 
    FROM intermediate_data
    
    UNION ALL
    
    -- Hospital occupancy
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 
           'Hospitalar' AS tipo_ocupacao, 'Clínico' AS tipo_leito, 
           ocupacao_hospitalar_cli AS ocupacao 
    FROM intermediate_data
    
    UNION ALL
    
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 
           'Hospitalar' AS tipo_ocupacao, 'UTI' AS tipo_leito, 
           ocupacao_hospitalar_uti AS ocupacao 
    FROM intermediate_data
),

-- Exit metrics (death/discharge) - keep separate to avoid duplication
saidas_data AS (
    SELECT
        id_registro,
        saida_confirmada_obitos,
        saida_confirmada_altas
    FROM intermediate_data
)

-- Final fact table assembly with performance optimizations
SELECT
    -- Same surrogate key generation as original
    {{ dbt_utils.generate_surrogate_key(['u.id_registro', 'ot.id_ocupacao_tipo']) }} AS id_fato,
    
    -- Dimension keys
    t.id_tempo,
    u.id_localidade,
    u.cnes AS id_cnes,
    ot.id_ocupacao_tipo,
    
    -- Metrics
    u.ocupacao AS quantidade_leitos_ocupados,
    s.saida_confirmada_obitos,
    s.saida_confirmada_altas,
    
    -- Metadata with performance tracking
    u.updated_at,
    
    -- Additional fields for performance analysis (testing only)
    u.data_notificacao,  -- Keep for partitioning tests
    CURRENT_TIMESTAMP() AS processed_at,
    '{{ invocation_id }}' AS dbt_run_id

FROM unpivoted_data u

-- Same joins as original
JOIN {{ ref('dim_tempo') }} t 
    ON DATE(u.data_notificacao) = t.data

JOIN {{ ref('dim_ocupacao_tipo') }} ot 
    ON u.tipo_ocupacao = ot.tipo_ocupacao 
    AND u.tipo_leito = ot.tipo_leito

LEFT JOIN saidas_data s 
    ON u.id_registro = s.id_registro

-- Same filter as original
WHERE u.ocupacao > 0

-- Optional: Add performance optimization hints for testing
{% if var('add_performance_hints', false) %}
ORDER BY t.id_tempo, u.id_localidade  -- Test clustering effect
{% endif %}