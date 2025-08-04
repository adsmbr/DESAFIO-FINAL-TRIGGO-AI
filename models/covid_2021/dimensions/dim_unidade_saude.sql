-- models/dimensions/dim_unidade_saude.sql
{{ config(materialized='table', schema='gold') }}
WITH unidades_distintas AS (
 SELECT DISTINCT
 TRIM(cnes) AS cnes
 FROM {{ ref('stg_leito_ocupacao_2021') }}
 WHERE cnes IS NOT NULL AND cnes != ''
)
SELECT
 cnes AS id_unidade_saude,
 cnes AS nome_unidade -- Pode ser enriquecido posteriormente com lookup de
nomes
FROM unidades_distintas
ORDER BY cnes
