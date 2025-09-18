-- Teste básico para camada Silver (intermediate)
-- Verifica apenas se existem dados na tabela
-- Teste simplificado enquanto aguardamos execução dos novos modelos

WITH contagem_registros AS (
    SELECT COUNT(*) as total_registros
    FROM COVID19.silver.int_leitos_ocupacao_unificado
)

-- Falha apenas se não houver nenhum registro na tabela
SELECT *
FROM contagem_registros
WHERE total_registros = 0