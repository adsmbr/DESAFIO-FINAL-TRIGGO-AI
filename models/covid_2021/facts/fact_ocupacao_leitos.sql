-- models/facts/fact_ocupacao_leitos.sql

-- Passo 1: Referenciar a camada intermediária (Silver), que já vem enriquecida com o id_localidade
WITH intermediate_data AS (
    SELECT 
        *
    FROM {{ ref('int_leitos_ocupacao_unificado') }}
    
    {% if is_incremental() %}
    -- Lógica incremental para processar apenas dados novos
    WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
    {% endif %}
),

-- Passo 2: Fazer o UNPIVOT completo de TODAS as colunas de ocupação
unpivoted_data AS (

    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'Suspeito' AS tipo_ocupacao, 'Clínico' AS tipo_leito, ocupacao_suspeito_cli AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'Suspeito' AS tipo_ocupacao, 'UTI' AS tipo_leito, ocupacao_suspeito_uti AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'Confirmado' AS tipo_ocupacao, 'Clínico' AS tipo_leito, ocupacao_confirmado_cli AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'Confirmado' AS tipo_ocupacao, 'UTI' AS tipo_leito, ocupacao_confirmado_uti AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'COVID' AS tipo_ocupacao, 'Clínico' AS tipo_leito, ocupacao_covid_cli AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'COVID' AS tipo_ocupacao, 'UTI' AS tipo_leito, ocupacao_covid_uti AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'Hospitalar' AS tipo_ocupacao, 'Clínico' AS tipo_leito, ocupacao_hospitalar_cli AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'Hospitalar' AS tipo_ocupacao, 'UTI' AS tipo_leito, ocupacao_hospitalar_uti AS ocupacao FROM intermediate_data
    
),

-- Passo 3: Trazer as métricas de saídas (óbito/alta) para evitar duplicação
saidas_data AS (
    SELECT
        id_registro,
        saida_confirmada_obitos,
        saida_confirmada_altas
    FROM intermediate_data
)

-- Passo 4: Montar a tabela de fatos final
SELECT
    -- Cria uma chave primária única para cada linha da tabela de fatos
    {{ dbt_utils.generate_surrogate_key(['u.id_registro', 'ot.id_ocupacao_tipo']) }} AS id_fato,
    
    -- Chaves de dimensão (Surrogate Keys)
    t.id_tempo,
    u.id_localidade, -- Esta chave já veio pronta da camada Silver
    u.cnes AS id_cnes,
    ot.id_ocupacao_tipo,
    
    -- Métricas
    u.ocupacao AS quantidade_leitos_ocupados,
    s.saida_confirmada_obitos,
    s.saida_confirmada_altas,

    -- Metadados
    u.updated_at

FROM unpivoted_data u

-- Join para buscar o id_tempo da dimensão de data
JOIN {{ ref('dim_data') }} t ON DATE(u.data_notificacao) = t.data

-- Join para buscar o id_ocupacao_tipo da dimensão de tipos
JOIN {{ ref('dim_ocupacao_tipo') }} ot ON u.tipo_ocupacao = ot.tipo_ocupacao AND u.tipo_leito = ot.tipo_leito

-- Join para trazer as métricas de saída sem duplicá-las
LEFT JOIN saidas_data s ON u.id_registro = s.id_registro

-- Filtra registros que não têm métricas de ocupação relevantes
WHERE u.ocupacao > 0