-- Teste para validar unicidade de IDs no modelo consolidado
-- Verifica se há IDs duplicados entre os anos

SELECT 
    id_registro,
    COUNT(*) as duplicate_count
FROM COVID19.bronze.stg_leito_ocupacao_consolidado
GROUP BY id_registro
HAVING COUNT(*) > 1