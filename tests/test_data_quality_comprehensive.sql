-- Test for data integrity and business logic validation
-- This test ensures data quality without breaking existing functionality

-- Test 1: Verify no negative bed occupancy
SELECT 
    'negative_occupancy' AS test_type,
    COUNT(*) AS failed_records
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE quantidade_leitos_ocupados < 0

UNION ALL

-- Test 2: Verify reasonable upper bounds for bed occupancy
SELECT 
    'unrealistic_high_occupancy' AS test_type,
    COUNT(*) AS failed_records
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE quantidade_leitos_ocupados > 10000

UNION ALL

-- Test 3: Verify data completeness for critical fields
SELECT 
    'missing_critical_data' AS test_type,
    COUNT(*) AS failed_records
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE id_tempo IS NULL 
   OR id_localidade IS NULL 
   OR id_ocupacao_tipo IS NULL

-- This test will fail only if any of these conditions return > 0 records
-- It's designed to be non-breaking and only validates data quality