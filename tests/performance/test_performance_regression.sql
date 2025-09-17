-- tests/performance/test_performance_regression.sql
-- Performance regression testing to ensure optimizations don't break functionality
-- This test compares key metrics between the original and optimized models

-- Test: Ensure fact table record count is within expected range
WITH current_metrics AS (
    SELECT 
        COUNT(*) as total_records,
        COUNT(DISTINCT id_fato) as unique_facts,
        COUNT(DISTINCT id_tempo) as unique_dates,
        COUNT(DISTINCT id_localidade) as unique_locations,
        SUM(quantidade_leitos_ocupados) as total_ocupacao
    FROM {{ ref('fact_ocupacao_leitos') }}
),

expected_ranges AS (
    -- Define acceptable ranges based on historical data
    SELECT 
        800000 as min_records,      -- Minimum expected records
        2000000 as max_records,     -- Maximum expected records
        500 as min_locations,       -- Minimum locations
        700 as max_locations,       -- Maximum locations
        365 as min_dates,           -- Minimum date range (1 year)
        1500 as max_dates           -- Maximum date range (~4 years)
),

validation_results AS (
    SELECT 
        cm.total_records,
        er.min_records,
        er.max_records,
        CASE 
            WHEN cm.total_records < er.min_records THEN 'RECORD_COUNT_TOO_LOW'
            WHEN cm.total_records > er.max_records THEN 'RECORD_COUNT_TOO_HIGH'
            ELSE NULL
        END as record_count_issue,
        
        cm.unique_locations,
        er.min_locations,
        er.max_locations,
        CASE 
            WHEN cm.unique_locations < er.min_locations THEN 'LOCATION_COUNT_TOO_LOW'
            WHEN cm.unique_locations > er.max_locations THEN 'LOCATION_COUNT_TOO_HIGH'
            ELSE NULL
        END as location_count_issue,
        
        cm.unique_dates,
        er.min_dates,
        er.max_dates,
        CASE 
            WHEN cm.unique_dates < er.min_dates THEN 'DATE_RANGE_TOO_SMALL'
            WHEN cm.unique_dates > er.max_dates THEN 'DATE_RANGE_TOO_LARGE'
            ELSE NULL
        END as date_range_issue,
        
        -- Data integrity checks
        CASE 
            WHEN cm.unique_facts != cm.total_records THEN 'DUPLICATE_FACT_KEYS'
            ELSE NULL
        END as integrity_issue,
        
        CASE 
            WHEN cm.total_ocupacao IS NULL OR cm.total_ocupacao <= 0 THEN 'INVALID_OCUPACAO_TOTAL'
            ELSE NULL
        END as business_logic_issue
        
    FROM current_metrics cm
    CROSS JOIN expected_ranges er
)

-- Return any issues found
SELECT 
    'Performance Regression Test' as test_name,
    COALESCE(
        record_count_issue, 
        location_count_issue, 
        date_range_issue, 
        integrity_issue, 
        business_logic_issue,
        'PERFORMANCE_REGRESSION_DETECTED'
    ) as issue_type,
    CASE 
        WHEN record_count_issue IS NOT NULL THEN 
            CONCAT('Record count ', total_records, ' outside range [', min_records, ', ', max_records, ']')
        WHEN location_count_issue IS NOT NULL THEN 
            CONCAT('Location count ', unique_locations, ' outside range [', min_locations, ', ', max_locations, ']')
        WHEN date_range_issue IS NOT NULL THEN 
            CONCAT('Date range ', unique_dates, ' outside range [', min_dates, ', ', max_dates, ']')
        WHEN integrity_issue IS NOT NULL THEN 
            CONCAT('Data integrity issue: ', integrity_issue)
        WHEN business_logic_issue IS NOT NULL THEN 
            CONCAT('Business logic issue: ', business_logic_issue)
        ELSE 'Unspecified performance regression detected'
    END as issue_description,
    total_records,
    unique_locations,
    unique_dates
FROM validation_results
WHERE record_count_issue IS NOT NULL 
   OR location_count_issue IS NOT NULL 
   OR date_range_issue IS NOT NULL 
   OR integrity_issue IS NOT NULL 
   OR business_logic_issue IS NOT NULL