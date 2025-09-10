-- Test for data completeness across time periods
-- Ensures we have data for expected date ranges without breaking existing models
-- This version uses a simple approach without external dependencies

SELECT 
    'missing_significant_dates' AS issue_type,
    COUNT(*) AS missing_count,
    'Found gaps in data coverage' AS description
FROM (
    -- Check if we have data for each expected year
    WITH yearly_coverage AS (
        SELECT 
            EXTRACT(YEAR FROM data_notificacao) AS data_year,
            COUNT(*) AS record_count
        FROM {{ ref('stg_leito_ocupacao_consolidado') }}
        WHERE data_notificacao IS NOT NULL
        GROUP BY EXTRACT(YEAR FROM data_notificacao)
    ),
    expected_years AS (
        SELECT 2020 AS expected_year
        UNION ALL
        SELECT 2021 AS expected_year  
        UNION ALL
        SELECT 2022 AS expected_year
    )
    -- Find missing years
    SELECT 
        ey.expected_year,
        COALESCE(yc.record_count, 0) AS actual_records
    FROM expected_years ey
    LEFT JOIN yearly_coverage yc ON ey.expected_year = yc.data_year
    WHERE COALESCE(yc.record_count, 0) = 0  -- No records for this year
)
-- This test passes if all expected years have data
-- It's designed to be informational rather than breaking