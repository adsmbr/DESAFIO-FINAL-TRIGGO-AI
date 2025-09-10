-- Modelo temporário para diagnosticar problemas na camada Silver
-- Execute com: dbt run --select silver_diagnostic

{{ config(
    materialized='table',
    schema='monitoring'
) }}

WITH staging_sample AS (
    SELECT 
        id_registro,
        data_notificacao,
        cnes,
        ano_dados,
        municipio_notificacao,
        estado_notificacao,
        municipio,
        estado
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    LIMIT 10  -- Apenas uma amostra para diagnosticar
),

intermediate_sample AS (
    SELECT 
        id_registro,
        data_notificacao,
        cnes,
        ano_dados,
        id_localidade
    FROM {{ ref('int_leitos_ocupacao_unificado') }}
    WHERE id_registro IN (SELECT id_registro FROM staging_sample)
),

problema_counts AS (
    SELECT 
        COUNT(*) as total_records,
        COUNT(CASE WHEN id_registro IS NULL THEN 1 END) as null_id_registro,
        COUNT(CASE WHEN data_notificacao IS NULL THEN 1 END) as null_data_notificacao,
        COUNT(CASE WHEN cnes IS NULL THEN 1 END) as null_cnes,
        COUNT(CASE WHEN TRIM(cnes) = '' THEN 1 END) as empty_cnes,
        COUNT(CASE WHEN id_localidade IS NULL THEN 1 END) as null_id_localidade,
        COUNT(CASE WHEN ano_dados IS NULL THEN 1 END) as null_ano_dados,
        COUNT(CASE WHEN ano_dados NOT IN (2020, 2021, 2022) THEN 1 END) as invalid_ano_dados
    FROM {{ ref('int_leitos_ocupacao_unificado') }}
)

SELECT 
    'DIAGNOSTICO_SILVER' as test_type,
    total_records,
    null_id_registro,
    null_data_notificacao, 
    null_cnes,
    empty_cnes,
    null_id_localidade,
    null_ano_dados,
    invalid_ano_dados,
    (null_id_registro + null_data_notificacao + null_cnes + empty_cnes + null_id_localidade + null_ano_dados + invalid_ano_dados) as total_problems,
    CURRENT_TIMESTAMP() as checked_at
FROM problema_counts