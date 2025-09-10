-- models/dimensions/dim_localidade.sql
-- Dimensão geográfica com estados e municípios brasileiros

WITH localidades_distintas AS (
    SELECT DISTINCT
        UPPER(TRIM(COALESCE(estado_notificacao, estado, 'DESCONHECIDO'))) AS estado,
        UPPER(TRIM(COALESCE(municipio_notificacao, municipio, 'DESCONHECIDO'))) AS municipio
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    WHERE 
        (estado IS NOT NULL OR municipio IS NOT NULL)
        AND TRIM(COALESCE(estado_notificacao, estado, '')) != ''
        AND TRIM(COALESCE(municipio_notificacao, municipio, '')) != ''
),
localidades_limpas AS (
    SELECT 
        estado,
        municipio,
        -- Adiciona informações úteis sobre a localidade
        CASE 
            WHEN estado = 'DESCONHECIDO' THEN 'Localização não informada'
            ELSE CONCAT(municipio, ' - ', estado)
        END AS localidade_completa
    FROM localidades_distintas
)
SELECT
    ROW_NUMBER() OVER (ORDER BY estado, municipio) AS id_localidade,
    estado,
    municipio,
    localidade_completa
FROM localidades_limpas

UNION ALL

-- Adiciona entrada padrão para casos não informados
SELECT
    -1 AS id_localidade,
    'NÃO INFORMADO' AS estado,
    'NÃO INFORMADO' AS municipio,
    'Localização não informada' AS localidade_completa

ORDER BY id_localidade, estado, municipio