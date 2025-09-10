-- Critical data quality test - only fails on serious data issues
-- This test only looks for problems that would break analysis

SELECT 
    'critical_data_issue' AS issue_type,
    COUNT(*) AS problem_count
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE 
    -- Only check for truly critical issues that would break analysis
    (quantidade_leitos_ocupados IS NULL)  -- Null values in key metric
    OR (id_tempo IS NULL)                 -- Missing time reference  
    OR (id_localidade IS NULL)           -- Missing location reference
    OR (quantidade_leitos_ocupados < 0)  -- Impossible negative values

-- This test only fails if there are actual critical data problems
-- Empty result = all critical checks pass