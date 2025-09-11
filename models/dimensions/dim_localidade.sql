-- models/dimensions/dim_localidade.sql
-- Dimensão geográfica com estados e municípios brasileiros

WITH localidades_distintas AS (
<<<<<<< HEAD
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
=======
 SELECT DISTINCT
 COALESCE(estado_notificacao, estado, 'Desconhecido') AS estado,
 COALESCE(municipio_notificacao, municipio, 'Desconhecido') AS municipio
 FROM {{ ref('stg_leito_ocupacao_consolidado') }}
 WHERE estado IS NOT NULL OR municipio IS NOT NULL
>>>>>>> 7c846bdd4ec2a2c2bb6f86b8c2099aed5f344ef3
)
SELECT
    ROW_NUMBER() OVER (ORDER BY estado, municipio) AS id_localidade,
    estado,
    municipio,
    localidade_completa
FROM localidades_limpas
ORDER BY estado, municipio