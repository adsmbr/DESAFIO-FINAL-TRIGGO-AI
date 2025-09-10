-- Comprehensive data quality validation
-- Only returns rows if there are actual data quality problems

SELECT 
    test_type,
    failed_records,
    'Data quality issue detected' AS description
FROM (
    -- Test 1: Check for negative bed occupancy (impossible values)
    SELECT 
        'negative_occupancy' AS test_type,
        COUNT(*) AS failed_records
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE quantidade_leitos_ocupados < 0

    UNION ALL

    -- Test 2: Check for extremely high values (likely data errors)
    SELECT 
        'unrealistic_high_occupancy' AS test_type,
        COUNT(*) AS failed_records
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE quantidade_leitos_ocupados > 10000

    UNION ALL

    -- Test 3: Check for missing critical dimension keys
    SELECT 
        'missing_dimension_keys' AS test_type,
        COUNT(*) AS failed_records
    FROM {{ ref('fact_ocupacao_leitos') }}
    WHERE id_tempo IS NULL 
       OR id_localidade IS NULL 
       OR id_ocupacao_tipo IS NULL
)
WHERE failed_records > 0  -- Only show actual problems

-- Empty result = all data quality checks pass
-- Any rows returned indicate specific data quality issues