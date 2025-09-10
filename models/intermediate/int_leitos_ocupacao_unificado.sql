-- models/intermediate/int_leitos_ocupacao_unificado.sql
-- Este modelo serve como ponte, enriquecendo os dados de staging com
-- as chaves das dimensões antes de carregar a tabela de fatos.
-- Inclui estratégia para lidar com localidades não encontradas

WITH staging_data AS (
    SELECT * FROM {{ ref('stg_leito_ocupacao_consolidado') }}
),

dim_localidade AS (
    SELECT * FROM {{ ref('dim_localidade') }}
),

-- Adiciona uma localidade padrão para casos não encontrados
dim_localidade_com_default AS (
    SELECT id_localidade, estado, municipio FROM dim_localidade
    UNION ALL
    SELECT -1 as id_localidade, 'NÃO INFORMADO' as estado, 'NÃO INFORMADO' as municipio
)

SELECT
    stg.*,  -- Seleciona todas as colunas originais do staging
    COALESCE(loc.id_localidade, -1) AS id_localidade -- Garante que sempre há um id_localidade

FROM staging_data stg

-- Faz o JOIN com a dimensão de localidade usando os nomes de texto
-- Usa estratégia mais tolerante para encontrar matches
LEFT JOIN dim_localidade_com_default loc ON
    UPPER(TRIM(COALESCE(stg.municipio_notificacao, stg.municipio, 'DESCONHECIDO'))) = UPPER(TRIM(loc.municipio))
    AND UPPER(TRIM(COALESCE(stg.estado_notificacao, stg.estado, 'DESCONHECIDO'))) = UPPER(TRIM(loc.estado))