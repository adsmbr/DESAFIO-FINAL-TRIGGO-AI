-- Data Quality Investigation Query
-- Run this manually to investigate data quality issues found by tests
-- This helps you understand what specific problems exist in your data

-- ==============================================
-- SECTION 1: Critical Data Issues Analysis
-- ==============================================

-- Check for NULL values in key metrics
SELECT 
    'NULL quantidade_leitos_ocupados' AS issue_type,
    COUNT(*) AS affected_records,
    'Records with NULL bed occupancy values' AS description
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE quantidade_leitos_ocupados IS NULL

UNION ALL

-- Check for missing time references
SELECT 
    'NULL id_tempo' AS issue_type,
    COUNT(*) AS affected_records,
    'Records missing time dimension reference' AS description
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE id_tempo IS NULL

UNION ALL

-- Check for missing location references  
SELECT 
    'NULL id_localidade' AS issue_type,
    COUNT(*) AS affected_records,
    'Records missing location dimension reference' AS description
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE id_localidade IS NULL

UNION ALL

-- Check for negative occupancy values
SELECT 
    'Negative occupancy' AS issue_type,
    COUNT(*) AS affected_records,
    'Records with impossible negative bed counts' AS description
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE quantidade_leitos_ocupados < 0

UNION ALL

-- Check for unrealistically high values
SELECT 
    'Extremely high occupancy' AS issue_type,
    COUNT(*) AS affected_records,
    'Records with suspiciously high bed counts (>10000)' AS description
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE quantidade_leitos_ocupados > 10000

-- ==============================================
-- SECTION 2: Sample Problematic Records
-- ==============================================

UNION ALL

SELECT 
    'SAMPLE_ISSUES' AS issue_type,
    0 AS affected_records,
    '--- Sample problematic records below ---' AS description

-- Note: To see actual sample records, run these queries separately:
/*
-- Sample records with NULL occupancy:
SELECT TOP 5 * 
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE quantidade_leitos_ocupados IS NULL;

-- Sample records with missing dimensions:
SELECT TOP 5 * 
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE id_tempo IS NULL OR id_localidade IS NULL;

-- Sample records with negative values:
SELECT TOP 5 * 
FROM {{ ref('fact_ocupacao_leitos') }}
WHERE quantidade_leitos_ocupados < 0;
*/