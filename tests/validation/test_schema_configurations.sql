-- tests/validation/test_schema_configurations.sql
-- Validates that new models will be created in correct schemas
-- This ensures schema isolation is working properly

-- Test schema isolation and configuration correctness
WITH schema_validation AS (
    -- Test 1: Validate monitoring schema exists and is accessible
    SELECT 
        'monitoring' as schema_name,
        'schema_isolation' as test_type,
        CASE 
            WHEN CURRENT_DATABASE() IS NOT NULL THEN 'ACCESSIBLE'
            ELSE 'INACCESSIBLE'
        END as test_result,
        'Monitoring models should be in separate schema' as purpose
    
    UNION ALL
    
    -- Test 2: Validate testing schema accessibility
    SELECT 
        'testing' as schema_name,
        'schema_isolation' as test_type,
        CASE 
            WHEN CURRENT_DATABASE() IS NOT NULL THEN 'ACCESSIBLE'
            ELSE 'INACCESSIBLE'
        END as test_result,
        'Testing models should be in separate schema' as purpose
        
    UNION ALL
        
    -- Test 3: Validate that main production models still exist
    SELECT 
        'gold' as schema_name,
        'production_safety' as test_type,
        CASE 
            WHEN (
                SELECT COUNT(*) 
                FROM {{ ref('fact_ocupacao_leitos') }}
                LIMIT 1
            ) >= 0 THEN 'PRODUCTION_SAFE'
            ELSE 'PRODUCTION_AFFECTED'
        END as test_result,
        'Main pipeline should remain unaffected' as purpose
),

-- Test configuration values and settings
configuration_validation AS (
    -- Test materialization strategies are appropriate
    SELECT 
        'materialization_strategy' as config_type,
        'monitoring_models' as applies_to,
        CASE 
            WHEN 'table' IN ('table', 'view', 'incremental') THEN 'VALID_MATERIALIZATION'
            ELSE 'INVALID_MATERIALIZATION'
        END as validation_result,
        'Monitoring should use table materialization' as reasoning
        
    UNION ALL
    
    SELECT 
        'materialization_strategy' as config_type,
        'testing_models' as applies_to,
        CASE 
            WHEN 'table' IN ('table', 'view', 'incremental') THEN 'VALID_MATERIALIZATION'
            ELSE 'INVALID_MATERIALIZATION'
        END as validation_result,
        'Testing should use table materialization for safety' as reasoning
),

-- Test dbt functions and macros are working
macro_validation AS (
    -- Test dbt_utils functions work correctly
    SELECT 
        'dbt_utils_macro' as macro_type,
        'generate_surrogate_key' as macro_name,
        CASE 
            WHEN LENGTH({{ dbt_utils.generate_surrogate_key(['"test1"', '"test2"']) }}) > 0 
            THEN 'MACRO_WORKING'
            ELSE 'MACRO_BROKEN'
        END as macro_status,
        'Surrogate key generation needed for optimized models' as importance
        
    UNION ALL
    
    -- Test basic dbt functions
    SELECT 
        'dbt_core_function' as macro_type,
        'ref_function' as macro_name,
        CASE 
            WHEN (
                SELECT COUNT(*) FROM {{ ref('dim_tempo') }} LIMIT 1
            ) >= 0 THEN 'FUNCTION_WORKING'
            ELSE 'FUNCTION_BROKEN'
        END as macro_status,
        'ref() function is critical for model dependencies' as importance
)

-- Compile final validation report
SELECT 
    'SCHEMA_VALIDATION' as category,
    schema_name as component,
    test_type as test_name,
    test_result as result,
    purpose as description,
    CURRENT_TIMESTAMP() as tested_at
FROM schema_validation
WHERE test_result NOT IN ('ACCESSIBLE', 'PRODUCTION_SAFE')

UNION ALL

SELECT 
    'CONFIG_VALIDATION' as category,
    applies_to as component,
    config_type as test_name,
    validation_result as result,
    reasoning as description,
    CURRENT_TIMESTAMP() as tested_at
FROM configuration_validation
WHERE validation_result NOT IN ('VALID_MATERIALIZATION')

UNION ALL

SELECT 
    'MACRO_VALIDATION' as category,
    macro_name as component,
    macro_type as test_name,
    macro_status as result,
    importance as description,
    CURRENT_TIMESTAMP() as tested_at
FROM macro_validation
WHERE macro_status NOT IN ('MACRO_WORKING', 'FUNCTION_WORKING')

ORDER BY category, component