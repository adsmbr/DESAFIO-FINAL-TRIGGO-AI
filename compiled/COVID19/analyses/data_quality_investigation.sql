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
FROM COVID19.gold.fact_ocupacao_leitos
WHERE quantidade_leitos_ocupados IS NULL

UNION ALL

-- Check for missing time references
SELECT 
    'NULL id_tempo' AS issue_type,
    COUNT(*) AS affected_records,
    'Records missing time dimension reference' AS description
FROM COVID19.gold.fact_ocupacao_leitos
WHERE id_tempo IS NULL

UNION ALL

-- Check for missing location references  
SELECT 
    'NULL id_localidade' AS issue_type,
    COUNT(*) AS affected_records,
    'Records missing location dimension reference' AS description
FROM COVID19.gold.fact_ocupacao_leitos
WHERE id_localidade IS NULL

UNION ALL

-- Check for negative occupancy values
SELECT 
    'Negative occupancy' AS issue_type,
    COUNT(*) AS affected_records,
    'Records with impossible negative bed counts' AS description
FROM COVID19.gold.fact_ocupacao_leitos
WHERE quantidade_leitos_ocupados < 0

UNION ALL

-- Check for unrealistically high values
SELECT 
    'Extremely high occupancy' AS issue_type,
    COUNT(*) AS affected_records,
    'Records with suspiciously high bed counts (>10000)' AS description
FROM COVID19.gold.fact_ocupacao_leitos
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
FROM COVID19.gold.fact_ocupacao_leitos
WHERE quantidade_leitos_ocupados IS NULL;

-- Sample records with missing dimensions:
SELECT TOP 5 * 
FROM COVID19.gold.fact_ocupacao_leitos
WHERE id_tempo IS NULL OR id_localidade IS NULL;

-- Sample records with negative values:
SELECT TOP 5 * 
FROM COVID19.gold.fact_ocupacao_leitos
WHERE quantidade_leitos_ocupados < 0;

-- ==============================================
-- SECTION 3: Data Distribution Analysis
-- ==============================================

-- Occupancy distribution by year
SELECT 
    t.ano,
    COUNT(*) AS total_records,
    AVG(f.quantidade_leitos_ocupados) AS avg_occupancy,
    MIN(f.quantidade_leitos_ocupados) AS min_occupancy,
    MAX(f.quantidade_leitos_ocupados) AS max_occupancy,
    SUM(f.quantidade_leitos_ocupados) AS total_occupancy
FROM COVID19.gold.fact_ocupacao_leitos f
JOIN COVID19.gold.dim_tempo t ON f.id_tempo = t.id_tempo
GROUP BY t.ano
ORDER BY t.ano;

-- Top 10 locations by total occupancy
SELECT 
    l.estado,
    l.municipio,
    COUNT(*) AS total_records,
    SUM(f.quantidade_leitos_ocupados) AS total_occupancy,
    AVG(f.quantidade_leitos_ocupados) AS avg_occupancy
FROM COVID19.gold.fact_ocupacao_leitos f
JOIN COVID19.gold.dim_localidade l ON f.id_localidade = l.id_localidade
GROUP BY l.estado, l.municipio
ORDER BY total_occupancy DESC
LIMIT 10;

-- Occupancy trends by quarter
SELECT 
    t.ano,
    t.trimestre,
    COUNT(*) AS total_records,
    AVG(f.quantidade_leitos_ocupados) AS avg_occupancy,
    SUM(f.saida_confirmada_obitos) AS total_deaths,
    SUM(f.saida_confirmada_altas) AS total_discharges
FROM COVID19.gold.fact_ocupacao_leitos f
JOIN COVID19.gold.dim_tempo t ON f.id_tempo = t.id_tempo
GROUP BY t.ano, t.trimestre
ORDER BY t.ano, t.trimestre;

-- Data quality by source year
SELECT 
    t.ano,
    COUNT(*) AS total_records,
    COUNT(CASE WHEN f.quantidade_leitos_ocupados IS NULL THEN 1 END) AS null_occupancy,
    COUNT(CASE WHEN f.id_localidade IS NULL THEN 1 END) AS missing_location,
    COUNT(CASE WHEN f.quantidade_leitos_ocupados < 0 THEN 1 END) AS negative_values,
    ROUND(
        100.0 * COUNT(CASE WHEN f.quantidade_leitos_ocupados IS NULL 
                             OR f.id_localidade IS NULL 
                             OR f.quantidade_leitos_ocupados < 0 THEN 1 END) / COUNT(*), 
        2
    ) AS quality_issues_percentage
FROM COVID19.gold.fact_ocupacao_leitos f
JOIN COVID19.gold.dim_tempo t ON f.id_tempo = t.id_tempo
GROUP BY t.ano
ORDER BY t.ano;
*/