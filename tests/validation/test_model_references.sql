-- tests/validation/test_model_references.sql
-- Validates that all model references in new models are correct
-- This ensures {{ ref('model_name') }} calls point to existing models

-- Test: Validate all referenced models exist and are accessible
WITH reference_validation AS (
    -- Test 1: Check if fact_ocupacao_leitos exists (referenced by monitoring models)
    SELECT 
        'fact_ocupacao_leitos' as referenced_model,
        'monitoring_models' as referenced_by,
        CASE 
            WHEN COUNT(*) > 0 THEN 'EXISTS'
            ELSE 'MISSING'
        END as reference_status
    FROM {{ ref('fact_ocupacao_leitos') }}
    LIMIT 1
    
    UNION ALL
    
    -- Test 2: Check if dim_tempo exists
    SELECT 
        'dim_tempo' as referenced_model,
        'monitoring_and_testing' as referenced_by,
        CASE 
            WHEN COUNT(*) > 0 THEN 'EXISTS'
            ELSE 'MISSING'
        END as reference_status
    FROM {{ ref('dim_tempo') }}
    LIMIT 1
    
    UNION ALL
    
    -- Test 3: Check if dim_localidade exists
    SELECT 
        'dim_localidade' as referenced_model,
        'monitoring_and_testing' as referenced_by,
        CASE 
            WHEN COUNT(*) > 0 THEN 'EXISTS'
            ELSE 'MISSING'
        END as reference_status
    FROM {{ ref('dim_localidade') }}
    LIMIT 1
    
    UNION ALL
    
    -- Test 4: Check if stg_leito_ocupacao_consolidado exists
    SELECT 
        'stg_leito_ocupacao_consolidado' as referenced_model,
        'monitoring_models' as referenced_by,
        CASE 
            WHEN COUNT(*) > 0 THEN 'EXISTS'
            ELSE 'MISSING'
        END as reference_status
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    LIMIT 1
    
    UNION ALL
    
    -- Test 5: Check if int_leitos_ocupacao_unificado exists
    SELECT 
        'int_leitos_ocupacao_unificado' as referenced_model,
        'testing_models' as referenced_by,
        CASE 
            WHEN COUNT(*) > 0 THEN 'EXISTS'
            ELSE 'MISSING'
        END as reference_status
    FROM {{ ref('int_leitos_ocupacao_unificado') }}
    LIMIT 1
    
    UNION ALL
    
    -- Test 6: Check if dim_ocupacao_tipo exists
    SELECT 
        'dim_ocupacao_tipo' as referenced_model,
        'testing_models' as referenced_by,
        CASE 
            WHEN COUNT(*) > 0 THEN 'EXISTS'
            ELSE 'MISSING'
        END as reference_status
    FROM {{ ref('dim_ocupacao_tipo') }}
    LIMIT 1
),

-- Test data quality and basic structure
data_structure_validation AS (
    SELECT 
        'fact_ocupacao_leitos' as model_name,
        'data_structure' as test_type,
        CASE 
            WHEN COUNT(DISTINCT id_fato) = COUNT(*) THEN 'UNIQUE_KEYS_OK'
            ELSE 'DUPLICATE_KEYS_FOUND'
        END as validation_result
    FROM {{ ref('fact_ocupacao_leitos') }}
    
    UNION ALL
    
    SELECT 
        'dim_tempo' as model_name,
        'data_structure' as test_type,
        CASE 
            WHEN COUNT(DISTINCT id_tempo) = COUNT(*) THEN 'UNIQUE_KEYS_OK'
            ELSE 'DUPLICATE_KEYS_FOUND'
        END as validation_result
    FROM {{ ref('dim_tempo') }}
)

-- Final validation report
SELECT 
    'REFERENCE_CHECK' as validation_type,
    referenced_model as model_name,
    referenced_by as used_by,
    reference_status as status,
    CURRENT_TIMESTAMP() as tested_at
FROM reference_validation
WHERE reference_status != 'EXISTS'  -- Only show problems

UNION ALL

SELECT 
    'DATA_STRUCTURE' as validation_type,
    model_name,
    test_type as used_by,
    validation_result as status,
    CURRENT_TIMESTAMP() as tested_at
FROM data_structure_validation
WHERE validation_result != 'UNIQUE_KEYS_OK'  -- Only show problems

ORDER BY validation_type, model_name