Projeto COVID19: Análise de Ocupação de Leitos (dbt)
1. Visão Geral do Projeto
Este projeto foi desenvolvido como solução para o desafio de engenharia de dados da Health Insights Brasil. O objetivo é transformar dados brutos de ocupação de leitos hospitalares do DataSUS, referentes aos anos de 2020, 2021 e 2022, em uma fonte de dados confiável, organizada e performática.
A solução implementa um pipeline de dados completo que ingere, transforma e modela os dados utilizando Snowflake como Data Warehouse e dbt (data build tool) para a transformação e modelagem, seguindo as melhores práticas de engenharia de dados.
O resultado final é um Modelo Dimensional (Star Schema) na camada GOLD, pronto para ser consumido por ferramentas de BI, permitindo que analistas e gestores de saúde pública extraiam insights acionáveis sobre a pandemia de COVID-19.
1.1 O Que é Este Projeto?
Imagine que temos uma montanha de dados sobre leitos hospitalares de vários anos, vindos de diferentes fontes e um pouco desorganizados. Este projeto funciona como um "grande organizador inteligente" para esses dados. Ele usa uma ferramenta chamada dbt (que significa "data build tool", ou "ferramenta de construção de dados") para:
Limpar os dados brutos de cada ano.
Unir os dados de todos os anos em um só lugar.
Organizar as informações em categorias lógicas (como data, localização e tipo de leito).
Preparar os dados para que possam ser facilmente usados em relatórios, gráficos e análises.
O objetivo final é ter um conjunto de dados único, confiável e fácil de consultar para entender a situação dos leitos hospitalares ao longo do tempo (2020, 2021 e 2022).
2. A Arquitetura de Dados: As "Camadas de Organização"
Para garantir que os dados são sempre de alta qualidade e fáceis de gerenciar, o projeto segue uma estratégia de organização em três "camadas". Pense nelas como diferentes estágios de refinamento dos dados:
a) Camada BRONZE (Staging - "Estágio Inicial")
Onde os dados ficam: Em um local específico no seu banco de dados (chamado "esquema") que nomeamos BRONZE.
O que acontece aqui: É o primeiro passo. Pegamos os dados brutos de cada ano, exatamente como eles vêm da fonte original, e fazemos apenas uma limpeza básica e padronização. É como tirar a poeira e organizar os papéis em pilhas iniciais, separadas por ano.
Objetivo: Ter uma cópia fiel e limpa dos dados originais de cada ano, pronta para o próximo passo.
b) Camada SILVER (Intermediate - "Estágio Intermediário")
Onde os dados ficam: Em um esquema chamado SILVER.
O que acontece aqui: Os dados da camada BRONZE (já consolidados de todos os anos) são combinados e enriquecidos. Por exemplo, podemos juntar informações de diferentes tabelas para criar uma visão mais completa. É como pegar as pilhas de papéis de todos os anos, juntar informações relacionadas e começar a preencher formulários para criar um registro único para cada evento.
Objetivo: Criar um conjunto de dados mais rico e consolidado, que serve de base para a camada final.
c) Camada GOLD (Consumption - "Estágio de Consumo")
Onde os dados ficam: Em um esquema chamado GOLD.
O que acontece aqui: Esta é a camada final, onde os dados são transformados em tabelas prontas para análise. Criamos dois tipos principais de tabelas:
Tabelas de Fatos: Contêm as "métricas" ou números que queremos analisar (ex: quantidade de leitos ocupados, número de óbitos).
Tabelas de Dimensão: Fornecem o "contexto" para as métricas (ex: informações sobre a data, o hospital, a localização, o tipo de ocupação).
Objetivo: Ser a camada que as pessoas de negócio (analistas, gestores) usam diretamente para criar os seus relatórios, gráficos e tomar decisões, sem precisar entender a complexidade dos dados brutos.
graph LR
A[Dados Brutos Originais (2020, 2021, 2022)] --> B(Esquema BRONZE);
B -- Limpeza e Padronização por Ano --> C(Consolidação de Anos);
C -- Combinação e Enriquecimento --> D[Esquema SILVER];
D -- Prontos para Análise --> E[Esquema GOLD];
E -- Uso Final --> F[Relatórios, Dashboards e Decisões];


3. Scripts de Ingestão e Automação (Snowflake)
Antes que o dbt possa começar a transformar os dados, eles precisam ser carregados para dentro do Snowflake. Estes scripts SQL são executados diretamente no Snowflake para criar as tabelas RAW e carregar os dados dos arquivos CSV do seu stage.
a) Criar Tabelas RAW (Estrutura)
Estes comandos criam as tabelas que irão receber os dados brutos de cada ano, espelhando a estrutura dos arquivos CSV.
-- Tabela para os dados brutos de 2020
CREATE OR REPLACE TABLE COVID19.BRONZE.RAW_LEITO_OCUPACAO_2020 (
    UNNAMED_O NUMBER(38,0),
    _ID VARCHAR(16777216),
    DATA_NOTIFICACAO TIMESTAMP_NTZ(9),
    CNES VARCHAR(16777216),
    OCUPACAO_SUSPEITO_CLI FLOAT,
    OCUPACAO_SUSPEITO_UTI FLOAT,
    OCUPACAO_CONFIRMADO_CLI FLOAT,
    OCUPACAO_CONFIRMADO_UTI FLOAT,
    OCUPACAO_COVID_UTI FLOAT,
    OCUPACAO_COVID_CLI FLOAT,
    OCUPACAO_HOSPITALAR_UTI FLOAT,
    OCUPACAO_HOSPITALAR_CLI FLOAT,
    SAIDA_SUSPEITA_OBITOS FLOAT,
    SAIDA_SUSPEITA_ALTAS FLOAT,
    SAIDA_CONFIRMADA_OBITOS FLOAT,
    SAIDA_CONFIRMADA_ALTAS FLOAT,
    ORIGEM VARCHAR(16777216),
    P_USUARIO VARCHAR(16777216),
    ESTADO_NOTIFICACAO VARCHAR(16777216),
    MUNICIPIO_NOTIFICACAO VARCHAR(16777216),
    ESTADO VARCHAR(16777216),
    MUNICIPIO VARCHAR(16777216),
    EXCLUIDO BOOLEAN,
    VALIDADO BOOLEAN,
    CREATED_AT TIMESTAMP_NTZ(9),
    UPDATED_AT TIMESTAMP_NTZ(9)
);

-- Tabela para os dados brutos de 2021
CREATE OR REPLACE TABLE COVID19.BRONZE.RAW_LEITO_OCUPACAO_2021 (
    UNNAMED_O NUMBER(38,0),
    _ID VARCHAR(16777216),
    DATA_NOTIFICACAO TIMESTAMP_NTZ(9),
    CNES VARCHAR(16777216),
    OCUPACAO_SUSPEITO_CLI FLOAT,
    OCUPACAO_SUSPEITO_UTI FLOAT,
    OCUPACAO_CONFIRMADO_CLI FLOAT,
    OCUPACAO_CONFIRMADO_UTI FLOAT,
    OCUPACAO_COVID_UTI FLOAT,
    OCUPACAO_COVID_CLI FLOAT,
    OCUPACAO_HOSPITALAR_UTI FLOAT,
    OCUPACAO_HOSPITALAR_CLI FLOAT,
    SAIDA_SUSPEITA_OBITOS FLOAT,
    SAIDA_SUSPEITA_ALTAS FLOAT,
    SAIDA_CONFIRMADA_OBITOS FLOAT,
    SAIDA_CONFIRMADA_ALTAS FLOAT,
    ORIGEM VARCHAR(16777216),
    P_USUARIO VARCHAR(16777216),
    ESTADO_NOTIFICACAO VARCHAR(16777216),
    MUNICIPIO_NOTIFICACAO VARCHAR(16777216),
    ESTADO VARCHAR(16777216),
    MUNICIPIO VARCHAR(16777216),
    EXCLUIDO BOOLEAN,
    VALIDADO BOOLEAN,
    CREATED_AT TIMESTAMP_NTZ(9),
    UPDATED_AT TIMESTAMP_NTZ(9)
);

-- Tabela para os dados brutos de 2022
CREATE OR REPLACE TABLE COVID19.BRONZE.RAW_LEITO_OCUPACAO_2022 (
    UNNAMED_O NUMBER(38,0),
    _ID VARCHAR(16777216),
    DATA_NOTIFICACAO TIMESTAMP_NTZ(9),
    CNES VARCHAR(16777216),
    OCUPACAO_SUSPEITO_CLI FLOAT,
    OCUPACAO_SUSPEITO_UTI FLOAT,
    OCUPACAO_CONFIRMADO_CLI FLOAT,
    OCUPACAO_CONFIRMADO_UTI FLOAT,
    OCUPACAO_COVID_UTI FLOAT,
    OCUPACAO_COVID_CLI FLOAT,
    OCUPACAO_HOSPITALAR_UTI FLOAT,
    OCUPACAO_HOSPITALAR_CLI FLOAT,
    SAIDA_SUSPEITA_OBITOS FLOAT,
    SAIDA_SUSPEITA_ALTAS FLOAT,
    SAIDA_CONFIRMADA_OBITOS FLOAT,
    SAIDA_CONFIRMADA_ALTAS FLOAT,
    ORIGEM VARCHAR(16777216),
    P_USUARIO VARCHAR(16777216),
    ESTADO_NOTIFICACAO VARCHAR(16777216),
    MUNICIPIO_NOTIFICACAO VARCHAR(16777216),
    ESTADO VARCHAR(16777216),
    MUNICIPIO VARCHAR(16777216),
    EXCLUIDO BOOLEAN,
    VALIDADO BOOLEAN,
    CREATED_AT TIMESTAMP_NTZ(9),
    UPDATED_AT TIMESTAMP_NTZ(9)
);

-- Tabela para os dados brutos de Municípios IBGE
CREATE OR REPLACE TABLE COVID19.BRONZE.RAW_MUNICIPIOS_IBGE (
    CODIGO_MUNICIPIO VARCHAR(16777216),
    NOME_MUNICIPIO VARCHAR(16777216),
    UF VARCHAR(16777216),
    CODIGO_UF VARCHAR(16777216)
);

-- Tabela para os dados brutos de Estabelecimentos CNES
CREATE OR REPLACE TABLE COVID19.BRONZE.RAW_ESTABELECIMENTOS_CNES (
    CO_CNES VARCHAR(16777216),
    NO_FANTASIA VARCHAR(16777216),
    TP_GESTAO VARCHAR(16777216),
    CO_CEP VARCHAR(16777216)
);


b) Carregar Dados para Tabelas RAW (COPY INTO)
Estes comandos carregam os dados dos arquivos CSV, que estão no seu stage no Snowflake, para as tabelas RAW criadas acima.
-- Carregar dados para a tabela RAW_LEITO_OCUPACAO_2020
COPY INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2020
FROM @COVID19.BRONZE.LEITO_OCUPACAO/esus-vepi.LeitoOcupacao_2020.csv
FILE_FORMAT = (
    TYPE = CSV,
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1,
    EMPTY_FIELD_AS_NULL = TRUE
    ON_ERROR = 'CONTINUE'
);

-- Carregar dados para a tabela RAW_LEITO_OCUPACAO_2021
COPY INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2021
FROM @COVID19.BRONZE.LEITO_OCUPACAO/esus-vepi.LeitoOcupacao_2021.csv
FILE_FORMAT = (
    TYPE = CSV,
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1,
    EMPTY_FIELD_AS_NULL = TRUE
    ON_ERROR = 'CONTINUE'
);

-- Carregar dados para a tabela RAW_LEITO_OCUPACAO_2022
COPY INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2022
FROM @COVID19.BRONZE.LEITO_OCUPACAO/esus-vepi.LeitoOcupacao_2022.csv
FILE_FORMAT = (
    TYPE = CSV,
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1,
    EMPTY_FIELD_AS_NULL = TRUE
    ON_ERROR = 'CONTINUE'
);

-- Carregar dados para a tabela RAW_MUNICIPIOS_IBGE
COPY INTO COVID19.BRONZE.RAW_MUNICIPIOS_IBGE
FROM @COVID19.BRONZE.LEITO_OCUPACAO/municipios.csv
FILE_FORMAT = (
    TYPE = CSV,
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1,
    EMPTY_FIELD_AS_NULL = TRUE
    ON_ERROR = 'CONTINUE'
);

-- Carregar dados para a tabela RAW_ESTABELECIMENTOS_CNES
COPY INTO COVID19.BRONZE.RAW_ESTABELECIMENTOS_CNES
FROM @COVID19.BRONZE.LEITO_OCUPACAO/cnes_estabelecimentos.csv
FILE_FORMAT = (
    TYPE = CSV,
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1,
    EMPTY_FIELD_AS_NULL = TRUE
    ON_ERROR = 'CONTINUE'
);


c) Conceder Privilégios (SELECT)
Estes comandos concedem as permissões de leitura necessárias para as roles que o dbt utiliza no Snowflake, garantindo que o dbt possa acessar as tabelas RAW.
-- Conceder privilégios de seleção nas tabelas RAW de ocupação de leitos
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_LEITO_OCUPACAO_2020 TO ROLE PC_DBT_DB_PICKER_ROLE;
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_LEITO_OCUPACAO_2020 TO ROLE PC_DBT_ROLE;
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_LEITO_OCUPACAO_2021 TO ROLE PC_DBT_DB_PICKER_ROLE;
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_LEITO_OCUPACAO_2021 TO ROLE PC_DBT_ROLE;
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_LEITO_OCUPACAO_2022 TO ROLE PC_DBT_DB_PICKER_ROLE;
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_LEITO_OCUPACAO_2022 TO ROLE PC_DBT_ROLE;

-- Conceder privilégios de seleção nas tabelas RAW de enriquecimento
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_MUNICIPIOS_IBGE TO ROLE PC_DBT_DB_PICKER_ROLE;
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_MUNICIPIOS_IBGE TO ROLE PC_DBT_ROLE;
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_ESTABELECIMENTOS_CNES TO ROLE PC_DBT_DB_PICKER_ROLE;
GRANT SELECT ON TABLE COVID19.BRONZE.RAW_ESTABELECIMENTOS_CNES TO ROLE PC_DBT_ROLE;


4. Estrutura de Pastas do Projeto
O projeto é organizado em pastas para manter tudo em ordem. A estrutura é simples e segue as convenções do dbt:
.
├── dbt_project.yml          # O "cérebro" do projeto: configurações gerais.
├── macros/                  # Pequenos programas que automatizam tarefas.
│   └── generate_schema_name.sql # Macro para definir nomes de esquemas.
├── models/                  # Onde ficam os arquivos SQL que transformam os dados.
│   ├── staging/             # Modelos da camada BRONZE.
│   │   ├── stg_leito_ocupacao_2020.sql # Novo modelo para dados de 2020.
│   │   ├── stg_leito_ocupacao_2021.sql # Modelo para dados de 2021.
│   │   ├── stg_leito_ocupacao_2022.sql # Novo modelo para dados de 2022.
│   │   ├── stg_leito_ocupacao_consolidado.sql # NOVO: Unifica os dados de todos os anos.
│   │   └── sources.yml      # Define as fontes de dados brutas.
│   ├── intermediate/        # Modelos da camada SILVER.
│   │   └── int_leitos_ocupacao_unificado.sql
│   ├── dimensions/          # Modelos de dimensão da camada GOLD.
│   │   ├── dim_cnes.sql
│   │   ├── dim_data.sql
│   │   ├── dim_localidade.sql
│   │   ├── dim_ocupacao_tipo.sql
│   │   ├── dim_tempo.sql
│   │   └── dim_unidade_saude.sql
│   └── facts/               # Modelos de fatos da camada GOLD.
│       └── fact_ocupacao_leitos.sql
└── tests/                   # Onde ficam os testes para garantir a qualidade dos dados.
    ├── test_no_future_dates.sql
    └── schema.yml           # Documentação e testes para os modelos.


5. Os Códigos Funcionais: O Que Cada Parte Faz
Vamos mergulhar nos arquivos mais importantes e entender o que cada linha de código faz, incluindo as atualizações para os anos adicionais.
a) dbt_project.yml: O "Manual de Instruções" do Projeto
Este é o arquivo central que diz ao dbt como o seu projeto deve ser construído. Ele define o nome do projeto, onde encontrar os arquivos e como materializar (criar) as tabelas em cada camada.
name: 'COVID19'          # O nome oficial do nosso projeto dbt.
version: '1.0.0'         # A versão atual do projeto.
config-version: 2        # Versão da configuração do dbt.
profile: 'default'       # Perfil de conexão usado para se conectar ao Snowflake.
model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]
target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  COVID19:
    staging:
      +materialized: view
      +schema: bronze
    intermediate:
      +materialized: table
      +schema: silver
    dimensions:
      +materialized: table
      +schema: gold
    facts:
      +materialized: incremental
      +schema: gold


b) macros/generate_schema_name.sql: A "Função Mágica dos Esquemas"
Esta macro é um pequeno pedaço de código que o dbt usa para decidir em qual esquema (pasta) do seu banco de dados cada tabela ou view deve ser criada. Ela garante que seus modelos vão para BRONZE, SILVER ou GOLD conforme configurado.
{% macro generate_schema_name(custom_schema_name, node) -%}
  {#
    Esta macro define como os nomes dos esquemas serão gerados.
    - custom_schema_name: O nome do esquema que definimos no dbt_project.yml (ex: 'bronze', 'silver', 'gold').
    - node: O objeto que representa o modelo atual que está sendo construído.
  #}

  {% set default_schema = target.schema -%}

  {%- if custom_schema_name is none -%}
    {{ default_schema }}
  {%- else -%}
    {{ custom_schema_name | trim }}
  {%-endif-%}

{%- endmacro %}


c) models/staging/sources.yml: O "Mapa das Fontes Originais"
Este arquivo diz ao dbt onde encontrar os dados brutos no seu banco de dados. É como um mapa que aponta para as tabelas originais, agora incluindo os dados de 2020 e 2022.
version: 2
sources:
  - name: bronze_source
    database: COVID19
    schema: BRONZE
    tables:
      - name: RAW_LEITO_OCUPACAO_2021
      - name: RAW_MUNICIPIOS_IBGE
      - name: RAW_ESTABELECIMENTOS_CNES
      - name: RAW_LEITO_OCUPACAO_2020
      - name: RAW_LEITO_OCUPACAO_2022


d) models/staging/stg_leito_ocupacao_2020.sql: "Primeira Limpeza 2020"
Este modelo processa os dados brutos de 2020, selecionando, renomeando e limpando as colunas.
SELECT
    _id AS id_registro,
    TO_TIMESTAMP_NTZ(data_notificacao) AS data_notificacao,
    TRIM(cnes) AS cnes,
    COALESCE(ocupacao_suspeito_cli, 0) AS ocupacao_suspeito_cli,
    COALESCE(ocupacao_suspeito_uti, 0) AS ocupacao_suspeito_uti,
    COALESCE(ocupacao_confirmado_cli, 0) AS ocupacao_confirmado_cli,
    COALESCE(ocupacao_confirmado_uti, 0) AS ocupacao_confirmado_uti,
    COALESCE(ocupacao_covid_uti, 0) AS ocupacao_covid_uti,
    COALESCE(ocupacao_covid_cli, 0) AS ocupacao_covid_cli,
    COALESCE(ocupacao_hospitalar_uti, 0) AS ocupacao_hospitalar_uti,
    COALESCE(ocupacao_hospitalar_cli, 0) AS ocupacao_hospitalar_cli,
    COALESCE(saida_suspeita_obitos, 0) AS saida_suspeita_obitos,
    COALESCE(saida_suspeita_altas, 0) AS saida_suspeita_altas,
    COALESCE(saida_confirmada_obitos, 0) AS saida_confirmada_obitos,
    COALESCE(saida_confirmada_altas, 0) AS saida_confirmada_altas,
    TRIM(origem) AS origem,
    TRIM(p_usuario) AS p_usuario,
    TRIM(estado_notificacao) AS estado_notificacao,
    TRIM(municipio_notificacao) AS municipio_notificacao,
    TRIM(estado) AS estado,
    TRIM(municipio) AS municipio,
    excluido,
    validado,
    created_at,
    updated_at,
    2020 AS ano_dados
FROM {{ source('bronze_source', 'RAW_LEITO_OCUPACAO_2020') }}
WHERE excluido = FALSE


e) models/staging/stg_leito_ocupacao_2021.sql: "Primeira Limpeza 2021"
Este modelo processa os dados brutos de 2021, selecionando, renomeando e limpando as colunas.
SELECT
    _id AS id_registro,
    TO_TIMESTAMP_NTZ(data_notificacao) AS data_notificacao,
    TRIM(cnes) AS cnes,
    COALESCE(ocupacao_suspeito_cli, 0) AS ocupacao_suspeito_cli,
    COALESCE(ocupacao_suspeito_uti, 0) AS ocupacao_suspeito_uti,
    COALESCE(ocupacao_confirmado_cli, 0) AS ocupacao_confirmado_cli,
    COALESCE(ocupacao_confirmado_uti, 0) AS ocupacao_confirmado_uti,
    COALESCE(ocupacao_covid_uti, 0) AS ocupacao_covid_uti,
    COALESCE(ocupacao_covid_cli, 0) AS ocupacao_covid_cli,
    COALESCE(ocupacao_hospitalar_uti, 0) AS ocupacao_hospitalar_uti,
    COALESCE(ocupacao_hospitalar_cli, 0) AS ocupacao_hospitalar_cli,
    COALESCE(saida_suspeita_obitos, 0) AS saida_suspeita_obitos,
    COALESCE(saida_suspeita_altas, 0) AS saida_suspeita_altas,
    COALESCE(saida_confirmada_obitos, 0) AS saida_confirmada_obitos,
    COALESCE(saida_confirmada_altas, 0) AS saida_confirmada_altas,
    TRIM(origem) AS origem,
    TRIM(p_usuario) AS p_usuario,
    TRIM(estado_notificacao) AS estado_notificacao,
    TRIM(municipio_notificacao) AS municipio_notificacao,
    TRIM(estado) AS estado,
    TRIM(municipio) AS municipio,
    excluido,
    validado,
    created_at,
    updated_at,
    2021 AS ano_dados
FROM {{ source('bronze_source', 'RAW_LEITO_OCUPACAO_2021') }}
WHERE excluido = FALSE


f) models/staging/stg_leito_ocupacao_2022.sql: "Primeira Limpeza 2022"
Este modelo processa os dados brutos de 2022, selecionando, renomeando e limpando as colunas.
SELECT
    _id AS id_registro,
    TO_TIMESTAMP_NTZ(data_notificacao) AS data_notificacao,
    TRIM(cnes) AS cnes,
    COALESCE(ocupacao_suspeito_cli, 0) AS ocupacao_suspeito_cli,
    COALESCE(ocupacao_suspeito_uti, 0) AS ocupacao_suspeito_uti,
    COALESCE(ocupacao_confirmado_cli, 0) AS ocupacao_confirmado_cli,
    COALESCE(ocupacao_confirmado_uti, 0) AS ocupacao_confirmado_uti,
    COALESCE(ocupacao_covid_uti, 0) AS ocupacao_covid_uti,
    COALESCE(ocupacao_covid_cli, 0) AS ocupacao_covid_cli,
    COALESCE(ocupacao_hospitalar_uti, 0) AS ocupacao_hospitalar_uti,
    COALESCE(ocupacao_hospitalar_cli, 0) AS ocupacao_hospitalar_cli,
    COALESCE(saida_suspeita_obitos, 0) AS saida_suspeita_obitos,
    COALESCE(saida_suspeita_altas, 0) AS saida_suspeita_altas,
    COALESCE(saida_confirmada_obitos, 0) AS saida_confirmada_obitos,
    COALESCE(saida_confirmada_altas, 0) AS saida_confirmada_altas,
    TRIM(origem) AS origem,
    TRIM(p_usuario) AS p_usuario,
    TRIM(estado_notificacao) AS estado_notificacao,
    TRIM(municipio_notificacao) AS municipio_notificacao,
    TRIM(estado) AS estado,
    TRIM(municipio) AS municipio,
    excluido,
    validado,
    created_at,
    updated_at,
    2022 AS ano_dados
FROM {{ source('bronze_source', 'RAW_LEITO_OCUPACAO_2022') }}
WHERE excluido = FALSE


g) models/staging/stg_leito_ocupacao_consolidado.sql: "União de Todos os Anos"
Este é o modelo-chave da camada BRONZE que une os dados de ocupação de leitos de todos os anos (2020, 2021 e 2022) em uma única tabela. Agora, todos os modelos seguintes (nas camadas Silver e Gold) só precisam se referir a este modelo consolidado.
-- Este modelo consolida os dados de ocupação de leitos de todos os anos.
-- Ele usa UNION ALL para combinar os resultados dos modelos de staging de cada ano.
SELECT * FROM {{ ref('stg_leito_ocupacao_2020') }}
UNION ALL
SELECT * FROM {{ ref('stg_leito_ocupacao_2021') }}
UNION ALL
SELECT * FROM {{ ref('stg_leito_ocupacao_2022') }}


h) models/intermediate/int_leitos_ocupacao_unificado.sql: O "Enriquecedor de Dados"
Este modelo da camada SILVER pega os dados consolidados da camada BRONZE e os combina com informações de outras dimensões (como a dimensão de localidade) para enriquecer os dados antes de criar a tabela de fatos. Ele foi atualizado para referenciar o modelo consolidado.
-- Este modelo serve como ponte, enriquecendo os dados de staging com
-- as chaves das dimensões antes de carregar a tabela de fatos.
-- Pega todos os dados do modelo de staging CONSOLIDADO (agora com todos os anos).
WITH staging_data AS (
    SELECT * FROM {{ ref('stg_leito_ocupacao_consolidado') }}
),
-- Pega todos os dados da dimensão de localidade (que já tem um ID único).
dim_localidade AS (
    SELECT * FROM {{ ref('dim_localidade') }}
)
-- Seleciona todas as colunas do staging e adiciona a chave da dimensão de localidade.
SELECT
    stg.*,                       -- Todas as colunas do modelo de staging.
    loc.id_localidade            -- O ID único da localidade (estado e município).
FROM staging_data stg
-- Conecta os dados de staging com a dimensão de localidade.
-- Usamos UPPER e COALESCE para garantir que a junção funcione mesmo com dados inconsistentes.
LEFT JOIN dim_localidade loc ON
    UPPER(COALESCE(stg.municipio_notificacao, stg.municipio, 'Desconhecido')) = UPPER(loc.municipio)
    AND UPPER(COALESCE(stg.estado_notificacao, stg.estado, 'Desconhecido')) = UPPER(loc.estado)


i) Modelos de Dimensão
Estes modelos criam as tabelas de dimensão na camada GOLD. Eles foram atualizados para referenciar o modelo consolidado (stg_leito_ocupacao_consolidado) quando necessário.
-- dim_cnes.sql
-- Este modelo cria a dimensão de estabelecimentos de saúde (CNES).
WITH estabelecimentos_cnes AS (
    SELECT
        CAST(CO_CNES AS STRING) AS id_cnes,
        NO_FANTASIA AS nm_estabelecimento
    FROM {{ source('bronze_source', 'RAW_ESTABELECIMENTOS_CNES') }}
),
-- Pega todos os códigos CNES únicos dos dados de leitos consolidados.
cnes_nos_dados AS (
    SELECT DISTINCT
        cnes AS id_cnes
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    WHERE cnes IS NOT NULL
)
-- Combina os CNES dos dados de leitos com os nomes dos estabelecimentos.
SELECT
    c.id_cnes,
    COALESCE(cnes.nm_estabelecimento, 'Não Informado') AS nm_estabelecimento
FROM cnes_nos_dados c
LEFT JOIN estabelecimentos_cnes cnes ON c.id_cnes = cnes.id_cnes
```sql
-- dim_data.sql
-- Este modelo cria a dimensão de tempo.
-- Pega todas as datas únicas dos dados de leitos consolidados.
WITH datas_distintas AS (
    SELECT DISTINCT CAST(data_notificacao AS DATE) AS data
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
)
-- Cria a tabela de dimensão de tempo com várias informações sobre cada data.
SELECT
    TO_CHAR(data, 'YYYYMMDD')::INT AS id_tempo,
    data,
    EXTRACT(YEAR FROM data) AS ano,
    EXTRACT(MONTH FROM data) AS mes,
    EXTRACT(DAY FROM data) AS dia,
    EXTRACT(DAYOFWEEK FROM data) AS dia_da_semana
FROM datas_distintas
ORDER BY data
```sql
-- dim_localidade.sql
-- Este modelo cria a dimensão geográfica (localidade).
-- Pega todos os estados e municípios únicos dos dados de leitos consolidados.
WITH localidades_distintas AS (
    SELECT DISTINCT
        COALESCE(estado_notificacao, estado, 'Desconhecido') AS estado,
        COALESCE (municipio_notificacao, municipio, 'Desconhecido') AS municipio
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    WHERE estado IS NOT NULL OR municipio IS NOT NULL
)
-- Cria a tabela de dimensão de localidade com um ID único para cada combinação.
SELECT
    ROW_NUMBER() OVER (ORDER BY estado, municipio) AS id_localidade,
    estado,
    municipio
FROM localidades_distintas
ORDER BY estado, municipio
```sql
-- dim_ocupacao_tipo.sql
-- Este modelo cria a dimensão de tipos de ocupação de leitos.
-- Os valores são fixos, não dependem dos dados de leitos.
SELECT * FROM (
    VALUES
    (1, 'Suspeito', 'Clínico'),
    (2, 'Suspeito', 'UTI'),
    (3, 'Confirmado', 'Clínico'),
    (4, 'Confirmado', 'UTI'),
    (5, 'COVID', 'Clínico'),
    (6, 'COVID', 'UTI'),
    (7, 'Hospitalar', 'Clínico'),
    (8, 'Hospitalar', 'UTI')
) AS t(id_ocupacao_tipo, tipo_ocupacao, tipo_leito)
```sql
-- dim_tempo.sql
-- Este modelo cria a dimensão de tempo detalhada.
-- Pega todas as datas únicas dos dados de leitos consolidados.
WITH date_spine AS (
    SELECT DISTINCT DATE(data_notificacao) AS data
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    WHERE data_notificacao IS NOT NULL
)
-- Cria a tabela de dimensão de tempo com várias informações sobre cada data.
SELECT
    TO_NUMBER(TO_CHAR(data, 'YYYYMMDD')) AS id_tempo,
    data,
    EXTRACT(DAY FROM data) AS dia,
    EXTRACT(MONTH FROM data) AS mes,
    MONTHNAME(data) AS nome_mes,
    EXTRACT(YEAR FROM data) AS ano,
    EXTRACT(DAYOFWEEK FROM data) AS dia_da_semana,
    DAYNAME(data) AS nome_dia_da_semana,
    EXTRACT(QUARTER FROM data) AS trimestre,
    EXTRACT(WEEK FROM data) AS semana_do_ano,
    FALSE AS feriado
FROM date_spine
ORDER BY data
```sql
-- dim_unidade_saude.sql
-- Este modelo cria a dimensão de unidades de saúde.
-- Pega todos os códigos CNES únicos dos dados de leitos consolidados.
WITH unidades_distintas AS (
    SELECT DISTINCT
        TRIM(cnes) AS cnes
    FROM {{ ref('stg_leito_ocupacao_consolidado') }}
    WHERE cnes IS NOT NULL AND cnes != ''
)
-- Cria a tabela de dimensão de unidade de saúde.
SELECT
    cnes AS id_unidade_saude,
    cnes AS nome_unidade
FROM unidades_distintas
ORDER BY cnes


j) models/facts/fact_ocupacao_leitos.sql: O "Coração do Sistema"
Este é o modelo da tabela de fatos da camada GOLD, que armazena as métricas de ocupação de leitos. Ele foi atualizado para usar o modelo intermediário, que já contém os dados consolidados de todos os anos.
-- Este modelo cria a tabela de fatos de ocupação de leitos.
-- Pega os dados do modelo intermediário (já enriquecido e consolidado).
WITH intermediate_data AS (
    SELECT * FROM {{ ref('int_leitos_ocupacao_unificado') }}
    {% if is_incremental() %}
        WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
    {% endif %}
),
-- Reorganiza os dados de ocupação para que cada linha represente um tipo de ocupação/leito.
unpivoted_data AS (
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'COVID' AS tipo_ocupacao, 'Clínico' AS tipo_leito, ocupacao_covid_cli AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'COVID' AS tipo_ocupacao, 'UTI' AS tipo_leito, ocupacao_covid_uti AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'Hospitalar' AS tipo_ocupacao, 'Clínico' AS tipo_leito, ocupacao_hospitalar_cli AS ocupacao FROM intermediate_data
    UNION ALL
    SELECT id_registro, data_notificacao, cnes, id_localidade, updated_at, 'Hospitalar' AS tipo_ocupacao, 'UTI' AS tipo_leito, ocupacao_hospitalar_uti AS ocupacao FROM intermediate_data
),
-- Pega as métricas de saída (óbito/alta) separadamente para evitar duplicação.
saidas_data AS (
    SELECT
        id_registro,
        saida_confirmada_obitos,
        saida_confirmada_altas
    FROM intermediate_data
)
-- Monta a tabela de fatos final, juntando com as dimensões.
SELECT
    {{ dbt_utils.generate_surrogate_key(['u.id_registro', 'ot.id_ocupacao_tipo']) }} AS id_fato,
    t.id_tempo,
    u.id_localidade,
    u.cnes AS id_cnes,
    ot.id_ocupacao_tipo,
    u.ocupacao AS quantidade_leitos_ocupados,
    s.saida_confirmada_obitos,
    s.saida_confirmada_altas,
    u.updated_at
FROM unpivoted_data u
JOIN {{ ref('dim_data') }} t ON DATE(u.data_notificacao) = t.data
JOIN {{ ref('dim_ocupacao_tipo') }} ot ON u.tipo_ocupacao = ot.tipo_ocupacao AND u.tipo_leito = ot.tipo_leito
LEFT JOIN saidas_data s ON u.id_registro = s.id_registro
WHERE u.ocupacao > 0


k) schema.yml: A "Documentação e Qualidade dos Dados"
Este arquivo é fundamental para documentar os seus modelos e fontes, e para definir testes de qualidade dos dados. Ele garante que os dados estão sempre corretos e completos.
version: 2
sources:
  - name: bronze_source
    database: COVID19
    schema: BRONZE
    tables:
      - name: RAW_LEITO_OCUPACAO_2021
      - name: RAW_MUNICIPIOS_IBGE
      - name: RAW_ESTABELECIMENTOS_CNES
      - name: RAW_LEITO_OCUPACAO_2020
      - name: RAW_LEITO_OCUPACAO_2022
models:
  - name: dim_tempo
    description: "Dimensão temporal com informações detalhadas sobre datas"
    columns:
      - name: id_tempo
        description: "Chave primária da dimensão tempo"
        tests:
          - unique
          - not_null
  - name: dim_localidade
    description: "Dimensão geográfica com estados e municípios"
    columns:
      - name: id_localidade
        description: "Chave primária da dimensão localidade"
        tests:
          - unique
          - not_null
  - name: fact_ocupacao_leitos
    description: "Tabela de fatos com métricas de ocupação de leitos"
    columns:
      - name: id_fato
        description: "Chave primária da tabela de fatos"
        tests:
          - unique
          - not_null


l) tests/test_no_future_dates.sql: O "Guardião das Datas"
Este é um exemplo de um teste de dados. Ele verifica se não há datas futuras na sua tabela de fatos, garantindo a integridade dos dados. Se encontrar alguma data futura, o teste falha, alertando para um problema.
SELECT *
FROM COVID19.GOLD.fact_ocupacao_leitos f
JOIN COVID19.GOLD.dim_tempo t ON f.id_tempo = t.id_tempo
WHERE t.data > CURRENT_DATE()


6. Orquestração e Automação: O Projeto em Produção
Para garantir que os dados estejam sempre atualizados e que as transformações rodem de forma consistente, implementamos a orquestração do projeto utilizando tanto os Jobs do dbt Cloud quanto as tasks nativas do Snowflake.
a) Orquestração com Jobs do dbt Cloud
A orquestração do projeto é realizada através de um Job de Produção no dbt Cloud.
Propósito: Automatizar a execução dos comandos dbt build em um ambiente de produção, garantindo que as camadas BRONZE, SILVER e GOLD estejam sempre atualizadas com os dados mais recentes.
Justificativa:
Confiabilidade: Elimina a necessidade de execução manual, reduzindo erros humanos.
Consistência: Assegura que todas as transformações e testes sejam aplicados de forma padronizada em intervalos regulares.
Atualidade: Os relatórios e dashboards que consomem os dados da camada GOLD terão sempre informações atualizadas.
Eficiência: O dbt otimiza o processamento, e o agendamento permite que as execuções ocorram em horários de menor demanda do banco de dados.
b) Fluxo de Trabalho do Job no dbt Cloud
O fluxo de trabalho de orquestração é simples e eficaz:
Agendamento: Um Job é configurado no dbt Cloud para ser executado em um horário fixo (ex: diariamente, de madrugada).
Comando Principal: O Job executa o comando dbt build --full-refresh.
dbt build: Compila e executa todos os modelos do projeto, respeitando as dependências entre as camadas (Staging -> Intermediate -> Dimensions/Facts).
--full-refresh: Garante que todas as tabelas e views sejam recriadas do zero a cada execução. Isso é ideal para garantir a limpeza completa e a consistência dos dados, especialmente durante a fase de desenvolvimento e para conjuntos de dados que não são excessivamente grandes ou que exigem uma reconstrução completa periódica.
Monitoramento: Notificações são configuradas para alertar a equipe em caso de falhas na execução do Job, permitindo uma rápida intervenção.
c) Automação de Ingestão Direta no Snowflake: Tasks e File Format
Para a ingestão dos dados brutos, foram criadas tasks diretamente no Snowflake. Essas tasks são responsáveis por carregar os arquivos CSV do stage para as tabelas RAW de cada ano. O uso de MERGE INTO garante que novos registros sejam inseridos sem duplicar dados já existentes, o que é crucial para a qualidade e consistência dos dados.
File Format (COVID_CSV_FORMAT)
Este comando cria um formato de arquivo que ajuda o Snowflake a interpretar corretamente os arquivos CSV.
-- criar file format
CREATE OR REPLACE FILE FORMAT COVID19.BRONZE.COVID_CSV_FORMAT
TYPE = CSV
FIELD_DELIMITER = ',',
SKIP_HEADER = 1,
EMPTY_FIELD_AS_NULL = TRUE;


Tasks para Ingestão e Mesclagem (MERGE)
Estes comandos criam tasks que automatizam o processo de mesclar novos dados nos arquivos brutos existentes. Esta abordagem é útil para atualizar os dados periodicamente, garantindo que os novos registros sejam adicionados e que os existentes não sejam duplicados.
-- Task para mesclar dados na tabela de 2020
create or replace task COVID19.BRONZE.COVID_2020_TASK_MERGE_INGEST
	warehouse=TRANSFORMING
	schedule='USING CRON 0 3 1 * * UTC'
	as MERGE INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2020 AS target
USING (
  SELECT
    $1 AS UNNAMED_0,
    $2 AS _ID,
    $3 AS DATA_NOTIFICACAO,
    $4 AS CNES,
    $5 AS OCUPACAO_SUSPEITO_CLI,
    $6 AS OCUPACAO_SUSPEITO_UTI,
    $7 AS OCUPACAO_CONFIRMADO_CLI,
    $8 AS OCUPACAO_CONFIRMADO_UTI,
    $9 AS OCUPACAO_COVID_UTI,
    $10 AS OCUPACAO_COVID_CLI,
    $11 AS OCUPACAO_HOSPITALAR_UTI,
    $12 AS OCUPACAO_HOSPITALAR_CLI,
    $13 AS SAIDA_SUSPEITA_OBITOS,
    $14 AS SAIDA_SUSPEITA_ALTAS,
    $15 AS SAIDA_CONFIRMADA_OBITOS,
    $16 AS SAIDA_CONFIRMADA_ALTAS,
    $17 AS ORIGEM,
    $18 AS P_USUARIO,
    $19 AS ESTADO_NOTIFICACAO,
    $20 AS MUNICIPIO_NOTIFICACAO,
    $21 AS ESTADO,
    $22 AS MUNICIPIO,
    $23 AS EXCLUIDO,
    $24 AS VALIDADO,
    $25 AS CREATED_AT,
    $26 AS UPDATED_AT
  FROM @COVID19.BRONZE.LEITO_OCUPACAO (FILE_FORMAT => covid_csv_format)
) AS source
ON target._ID = source._ID
WHEN NOT MATCHED THEN
  INSERT (
    UNNAMED_0, _ID, DATA_NOTIFICACAO, CNES,
    OCUPACAO_SUSPEITO_CLI, OCUPACAO_SUSPEITO_UTI,
    OCUPACAO_CONFIRMADO_CLI, OCUPACAO_CONFIRMADO_UTI,
    OCUPACAO_COVID_UTI, OCUPACAO_COVID_CLI,
    OCUPACAO_HOSPITALAR_UTI, OCUPACAO_HOSPITALAR_CLI,
    SAIDA_SUSPEITA_OBITOS, SAIDA_SUSPEITA_ALTAS,
    SAIDA_CONFIRMADA_OBITOS, SAIDA_CONFIRMADA_ALTAS,
    ORIGEM, P_USUARIO, ESTADO_NOTIFICACAO, MUNICIPIO_NOTIFICACAO,
    ESTADO, MUNICIPIO, EXCLUIDO, VALIDADO, CREATED_AT, UPDATED_AT
  )
  VALUES (
    source.UNNAMED_0, source._ID, source.DATA_NOTIFICACAO, source.CNES,
    source.OCUPACAO_SUSPEITO_CLI, source.OCUPACAO_SUSPEITO_UTI,
    source.OCUPACAO_CONFIRMADO_CLI, source.OCUPACAO_CONFIRMADO_UTI,
    source.OCUPACAO_COVID_UTI, source.OCUPACAO_COVID_CLI,
    source.OCUPACAO_HOSPITALAR_UTI, source.OCUPACAO_HOSPITALAR_CLI,
    source.SAIDA_SUSPEITA_OBITOS, source.SAIDA_SUSPEITA_ALTAS,
    source.SAIDA_CONFIRMADA_OBITOS, source.SAIDA_CONFIRMADA_ALTAS,
    source.ORIGEM, source.P_USUARIO, source.ESTADO_NOTIFICACAO, source.MUNICIPIO_NOTIFICACAO,
    source.ESTADO, source.MUNICIPIO, source.EXCLUIDO, source.VALIDADO, source.CREATED_AT, source.UPDATED_AT
  );

-- Task para mesclar dados na tabela de 2021
create or replace task COVID19.BRONZE.COVID_2021_TASK_MERGE_INGEST
	warehouse=TRANSFORMING
	schedule='USING CRON 0 3 1 * * UTC'
	as MERGE INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2021 AS target
USING (
  SELECT
    $1 AS UNNAMED_0,
    $2 AS _ID,
    $3 AS DATA_NOTIFICACAO,
    $4 AS CNES,
    $5 AS OCUPACAO_SUSPEITO_CLI,
    $6 AS OCUPACAO_SUSPEITO_UTI,
    $7 AS OCUPACAO_CONFIRMADO_CLI,
    $8 AS OCUPACAO_CONFIRMADO_UTI,
    $9 AS OCUPACAO_COVID_UTI,
    $10 AS OCUPACAO_COVID_CLI,
    $11 AS OCUPACAO_HOSPITALAR_UTI,
    $12 AS OCUPACAO_HOSPITALAR_CLI,
    $13 AS SAIDA_SUSPEITA_OBITOS,
    $14 AS SAIDA_SUSPEITA_ALTAS,
    $15 AS SAIDA_CONFIRMADA_OBITOS,
    $16 AS SAIDA_CONFIRMADA_ALTAS,
    $17 AS ORIGEM,
    $18 AS P_USUARIO,
    $19 AS ESTADO_NOTIFICACAO,
    $20 AS MUNICIPIO_NOTIFICACAO,
    $21 AS ESTADO,
    $22 AS MUNICIPIO,
    $23 AS EXCLUIDO,
    $24 AS VALIDADO,
    $25 AS CREATED_AT,
    $26 AS UPDATED_AT
  FROM @COVID19.BRONZE.LEITO_OCUPACAO (FILE_FORMAT => covid_csv_format)
) AS source
ON target._ID = source._ID
WHEN NOT MATCHED THEN
  INSERT (
    UNNAMED_0, _ID, DATA_NOTIFICACAO, CNES,
    OCUPACAO_SUSPEITO_CLI, OCUPACAO_SUSPEITO_UTI,
    OCUPACAO_CONFIRMADO_CLI, OCUPACAO_CONFIRMADO_UTI,
    OCUPACAO_COVID_UTI, OCUPACAO_COVID_CLI,
    OCUPACAO_HOSPITALAR_UTI, OCUPACAO_HOSPITALAR_CLI,
    SAIDA_SUSPEITA_OBITOS, SAIDA_SUSPEITA_ALTAS,
    SAIDA_CONFIRMADA_OBITOS, SAIDA_CONFIRMADA_ALTAS,
    ORIGEM, P_USUARIO, ESTADO_NOTIFICACAO, MUNICIPIO_NOTIFICACAO,
    ESTADO, MUNICIPIO, EXCLUIDO, VALIDADO, CREATED_AT, UPDATED_AT
  )
  VALUES (
    source.UNNAMED_0, source._ID, source.DATA_NOTIFICACAO, source.CNES,
    source.OCUPACAO_SUSPEITO_CLI, source.OCUPACAO_SUSPEITO_UTI,
    source.OCUPACAO_CONFIRMADO_CLI, source.OCUPACAO_CONFIRMADO_UTI,
    source.OCUPACAO_COVID_UTI, source.OCUPACAO_COVID_CLI,
    source.OCUPACAO_HOSPITALAR_UTI, source.OCUPACAO_HOSPITALAR_CLI,
    source.SAIDA_SUSPEITA_OBITOS, source.SAIDA_SUSPEITA_ALTAS,
    source.SAIDA_CONFIRMADA_OBITOS, source.SAIDA_CONFIRMADA_ALTAS,
    source.ORIGEM, source.P_USUARIO, source.ESTADO_NOTIFICACAO, source.MUNICIPIO_NOTIFICACAO,
    source.ESTADO, source.MUNICIPIO, source.EXCLUIDO, source.VALIDADO, source.CREATED_AT, source.UPDATED_AT
  );

-- Task para mesclar dados na tabela de 2022
create or replace task COVID19.BRONZE.COVID_2022_TASK_MERGE_INGEST
	warehouse=TRANSFORMING
	schedule='USING CRON 0 3 1 * * UTC'
	as MERGE INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2022 AS target
USING (
  SELECT
    $1 AS UNNAMED_0,
    $2 AS _ID,
    $3 AS DATA_NOTIFICACAO,
    $4 AS CNES,
    $5 AS OCUPACAO_SUSPEITO_CLI,
    $6 AS OCUPACAO_SUSPEITO_UTI,
    $7 AS OCUPACAO_CONFIRMADO_CLI,
    $8 AS OCUPACAO_CONFIRMADO_UTI,
    $9 AS OCUPACAO_COVID_UTI,
    $10 AS OCUPACAO_COVID_CLI,
    $11 AS OCUPACAO_HOSPITALAR_UTI,
    $12 AS OCUPACAO_HOSPITALAR_CLI,
    $13 AS SAIDA_SUSPEITA_OBITOS,
    $14 AS SAIDA_SUSPEITA_ALTAS,
    $15 AS SAIDA_CONFIRMADA_OBITOS,
    $16 AS SAIDA_CONFIRMADA_ALTAS,
    $17 AS ORIGEM,
    $18 AS P_USUARIO,
    $19 AS ESTADO_NOTIFICACAO,
    $20 AS MUNICIPIO_NOTIFICACAO,
    $21 AS ESTADO,
    $22 AS MUNICIPIO,
    $23 AS EXCLUIDO,
    $24 AS VALIDADO,
    $25 AS CREATED_AT,
    $26 AS UPDATED_AT
  FROM @COVID19.BRONZE.LEITO_OCUPACAO (FILE_FORMAT => covid_csv_format)
) AS source
ON target._ID = source._ID
WHEN NOT MATCHED THEN
  INSERT (
    UNNAMED_0, _ID, DATA_NOTIFICACAO, CNES,
    OCUPACAO_SUSPEITO_CLI, OCUPACAO_SUSPEITO_UTI,
    OCUPACAO_CONFIRMADO_CLI, OCUPACAO_CONFIRMADO_UTI,
    OCUPACAO_COVID_UTI, OCUPACAO_COVID_CLI,
    OCUPACAO_HOSPITALAR_UTI, OCUPACAO_HOSPITALAR_CLI,
    SAIDA_SUSPEITA_OBITOS, SAIDA_SUSPEITA_ALTAS,
    SAIDA_CONFIRMADA_OBITOS, SAIDA_CONFIRMADA_ALTAS,
    ORIGEM, P_USUARIO, ESTADO_NOTIFICACAO, MUNICIPIO_NOTIFICACAO,
    ESTADO, MUNICIPIO, EXCLUIDO, VALIDADO, CREATED_AT, UPDATED_AT
  )
  VALUES (
    source.UNNAMED_0, source._ID, source.DATA_NOTIFICACAO, source.CNES,
    source.OCUPACAO_SUSPEITO_CLI, source.OCUPACAO_SUSPEITO_UTI,
    source.OCUPACAO_CONFIRMADO_CLI, source.OCUPACAO_CONFIRMADO_UTI,
    source.OCUPACAO_COVID_UTI, source.OCUPACAO_COVID_CLI,
    source.OCUPACAO_HOSPITALAR_UTI, source.OCUPACAO_HOSPITALAR_CLI,
    source.SAIDA_SUSPEITA_OBITOS, source.SAIDA_SUSPEITA_ALTAS,
    source.SAIDA_CONFIRMADA_OBITOS, source.SAIDA_CONFIRMADA_ALTAS,
    source.ORIGEM, source.P_USUARIO, source.ESTADO_NOTIFICACAO, source.MUNICIPIO_NOTIFICACAO,
    source.ESTADO, source.MUNICIPIO, source.EXCLUIDO, source.VALIDADO, source.CREATED_AT, source.UPDATED_AT
  );

-- Task para mesclar dados na tabela de 2022
create or replace task COVID19.BRONZE.COVID_2022_TASK_MERGE_INGEST
	warehouse=TRANSFORMING
	schedule='USING CRON 0 3 1 * * UTC'
	as MERGE INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2022 AS target
USING (
  SELECT
    $1 AS UNNAMED_0,
    $2 AS _ID,
    $3 AS DATA_NOTIFICACAO,
    $4 AS CNES,
    $5 AS OCUPACAO_SUSPEITO_CLI,
    $6 AS OCUPACAO_SUSPEITO_UTI,
    $7 AS OCUPACAO_CONFIRMADO_CLI,
    $8 AS OCUPACAO_CONFIRMADO_UTI,
    $9 AS OCUPACAO_COVID_UTI,
    $10 AS OCUPACAO_COVID_CLI,
    $11 AS OCUPACAO_HOSPITALAR_UTI,
    $12 AS OCUPACAO_HOSPITALAR_CLI,
    $13 AS SAIDA_SUSPEITA_OBITOS,
    $14 AS SAIDA_SUSPEITA_ALTAS,
    $15 AS SAIDA_CONFIRMADA_OBITOS,
    $16 AS SAIDA_CONFIRMADA_ALTAS,
    $17 AS ORIGEM,
    $18 AS P_USUARIO,
    $19 AS ESTADO_NOTIFICACAO,
    $20 AS MUNICIPIO_NOTIFICACAO,
    $21 AS ESTADO,
    $22 AS MUNICIPIO,
    $23 AS EXCLUIDO,
    $24 AS VALIDADO,
    $25 AS CREATED_AT,
    $26 AS UPDATED_AT
  FROM @COVID19.BRONZE.LEITO_OCUPACAO (FILE_FORMAT => covid_csv_format)
) AS source
ON target._ID = source._ID
WHEN NOT MATCHED THEN
  INSERT (
    UNNAMED_0, _ID, DATA_NOTIFICACAO, CNES,
    OCUPACAO_SUSPEITO_CLI, OCUPACAO_SUSPEITO_UTI,
    OCUPACAO_CONFIRMADO_CLI, OCUPACAO_CONFIRMADO_UTI,
    OCUPACAO_COVID_UTI, OCUPACAO_COVID_CLI,
    OCUPACAO_HOSPITALAR_UTI, OCUPACAO_HOSPITALAR_CLI,
    SAIDA_SUSPEITA_OBITOS, SAIDA_SUSPEITA_ALTAS,
    SAIDA_CONFIRMADA_OBITOS, SAIDA_CONFIRMADA_ALTAS,
    ORIGEM, P_USUARIO, ESTADO_NOTIFICACAO, MUNICIPIO_NOTIFICACAO,
    ESTADO, MUNICIPIO, EXCLUIDO, VALIDADO, CREATED_AT, UPDATED_AT
  )
  VALUES (
    source.UNNAMED_0, source._ID, source.DATA_NOTIFICACAO, source.CNES,
    source.OCUPACAO_SUSPEITO_CLI, source.OCUPACAO_SUSPEITO_UTI,
    source.OCUPACAO_CONFIRMADO_CLI, source.OCUPACAO_CONFIRMADO_UTI,
    source.OCUPACAO_COVID_UTI, source.OCUPACAO_COVID_CLI,
    source.OCUPACAO_HOSPITALAR_UTI, source.OCUPACAO_HOSPITALAR_CLI,
    source.SAIDA_SUSPEITA_OBITOS, source.SAIDA_SUSPEITA_ALTAS,
    source.SAIDA_CONFIRMADA_OBITOS, source.SAIDA_CONFIRMADA_ALTAS,
    source.ORIGEM, source.P_USUARIO, source.ESTADO_NOTIFICACAO, source.MUNICIPIO_NOTIFICACAO,
    source.ESTADO, source.MUNICIPIO, source.EXCLUIDO, source.VALIDADO, source.CREATED_AT, source.UPDATED_AT
  );


Tasks para Ingestão (COPY INTO)
-- Task para automação da ingestão de 2020
create or replace task COVID19.BRONZE.COVID_2020_TASK_INGEST
	warehouse=TRANSFORMING
	schedule='USING CRON 0 3 1 * * UTC'
	as COPY INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2020
  FROM @COVID19.BRONZE.LEITO_OCUPACAO/esus-vepi.LeitoOcupacao_2020.csv
  FILE_FORMAT = covid_csv_format
  ON_ERROR = 'CONTINUE';

-- Task para automação da ingestão de 2021
create or replace task COVID19.BRONZE.COVID_2021_TASK_INGEST
	warehouse=TRANSFORMING
	schedule='USING CRON 0 3 1 * * UTC'
	as COPY INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2021
  FROM @COVID19.BRONZE.LEITO_OCUPACAO/esus-vepi.LeitoOcupacao_2021.csv
  FILE_FORMAT = covid_csv_format
  ON_ERROR = 'CONTINUE';

-- Task para automação da ingestão de 2022
create or replace task COVID19.BRONZE.COVID_2022_TASK_INGEST
	warehouse=TRANSFORMING
	schedule='USING CRON 0 3 1 * * UTC'
	as COPY INTO COVID19.BRONZE.RAW_LEITO_OCUPACAO_2022
  FROM @COVID19.BRONZE.LEITO_OCUPACAO/esus-vepi.LeitoOcupacao_2022.csv
  FILE_FORMAT = covid_csv_format
  ON_ERROR = 'CONTINUE';


7. Inovação e Diferenciação: O Que Torna Este Projeto Especial
Este projeto incorpora diversas inovações e boas práticas que o tornam uma solução robusta e moderna para análise de dados de saúde pública:
a) Modelagem Dimensional Orientada a Insights
O esquema estrela foi cuidadosamente projetado não apenas para armazenar dados, mas para facilitar a extração de insights acionáveis. A criação de dimensões como DIM_OCUPACAO_TIPO (que categoriza tipos de ocupação e leito) e a unificação de dados de diferentes anos (2020, 2021, 2022) na camada de fatos, mesmo com fontes separadas, demonstram uma preocupação em tornar a análise mais intuitiva e poderosa. Isso permite que analistas de saúde investiguem rapidamente padrões de ocupação por tipo de COVID, tipo de leito, e comparem tendências ao longo dos anos.
b) Abordagem Data-as-Code com dbt
A utilização do dbt eleva a engenharia de dados a um novo patamar, tratando as transformações SQL como código de software. Isso permite:
Controle de Versão: Todas as transformações são versionadas no Git, garantindo rastreabilidade, histórico de mudanças e colaboração entre desenvolvedores.
Testes Automatizados: A inclusão de testes (e.g., test_no_future_dates.sql e testes de unique/not_null em schema.yml) assegura a qualidade e a integridade dos dados, um aspecto crítico em dados de saúde, onde a precisão é vital.
Documentação Automática: O dbt gera documentação interativa do modelo de dados, promovendo a transparência e reduzindo a dependência de documentação manual desatualizada.
Reutilização de Código: A modularização dos modelos dbt (camadas staging, intermediate, dimensions, facts) promove a reutilização de código SQL e facilita a manutenibilidade do projeto.
c) Pipeline Incremental para Fatos
A materialização incremental da tabela FACT_OCUPACAO_LEITOS é uma inovação crucial para lidar com grandes volumes de dados que crescem continuamente. Ao processar apenas os novos registros (baseado na coluna updated_at), a solução otimiza o uso de recursos computacionais no Snowflake, reduzindo custos e tempo de execução. Isso é essencial para pipelines de dados em produção, garantindo atualizações rápidas e eficientes.
d) Tratamento Inteligente de Dados Brutos
A estratégia de tratamento de nulos (COALESCE) e padronização de colunas (como TRIM em cnes e estado/municipio) diretamente nas transformações dbt demonstra uma abordagem proativa para lidar com a qualidade dos dados na fonte. Isso garante que os dados modelados sejam limpos e consistentes para análise, mesmo com as imperfeições dos dados brutos do DataSUS.
e) Flexibilidade para Análise Temporal e Geográfica
A criação de dimensões robustas como DIM_TEMPO (com granularidade de dia, mês, ano, semana, trimestre) e DIM_LOCALIDADE (estado e município) permite análises multidimensionais flexíveis. Isso é fundamental para entender a dinâmica da ocupação de leitos em diferentes períodos e regiões, apoiando decisões estratégicas em saúde pública.
Essas inovações, combinadas com a escolha de tecnologias de ponta como Snowflake e dbt, resultam em uma solução de engenharia de dados que não é apenas funcional, mas também eficiente, confiável e preparada para o futuro.
8. Como Executar o Projeto
Para construir todo o projeto e criar as tabelas e views no seu banco de dados, você só precisa de um comando no terminal do dbt Cloud:
dbt build --full-refresh
Este comando:
dbt build: Executa todos os modelos e testes do seu projeto.
--full-refresh: Garante que todas as tabelas e views sejam recriadas do zero, o que é útil após alterações na estrutura ou para garantir que não há dados antigos.
9. Exemplos de Consultas e Insights
Para demonstrar a utilidade das tabelas da camada GOLD, aqui estão alguns exemplos de consultas SQL que podem ser usadas para obter insights relevantes sobre a saúde pública.
Exemplo 1: Total de leitos de UTI ocupados por COVID em São Paulo durante o ano de 2021.
SELECT
    dl.estado,
    dl.municipio,
    dt.ano,
    SUM(fol.quantidade_leitos_ocupados) AS total_leitos_uti_covid
FROM COVID19.GOLD.fact_ocupacao_leitos AS fol
JOIN COVID19.GOLD.dim_localidade AS dl
    ON fol.id_localidade = dl.id_localidade
JOIN COVID19.GOLD.dim_tempo AS dt
    ON fol.id_tempo = dt.id_tempo
JOIN COVID19.GOLD.dim_ocupacao_tipo AS dot
    ON fol.id_ocupacao_tipo = dot.id_ocupacao_tipo
WHERE
    dl.estado = 'São Paulo'
    AND dot.tipo_ocupacao = 'COVID'
    AND dot.tipo_leito = 'UTI'
    AND dt.ano = 2021
GROUP BY
    dl.estado,
    dl.municipio,
    dt.ano
ORDER BY
    total_leitos_uti_covid DESC;


Insight: Esta consulta mostra a carga de leitos de UTI específicos para COVID-19 por município em São Paulo, permitindo que as autoridades de saúde identifiquem as áreas com maior demanda e aloquem recursos de forma mais eficiente.
Exemplo 2: Variação mensal de óbitos por COVID confirmados em 2022.
WITH saidas_mensais AS (
    SELECT
        dt.ano,
        dt.mes,
        SUM(saida_confirmada_obitos) AS obitos_mes
    FROM COVID19.GOLD.fact_ocupacao_leitos AS fol
    JOIN COVID19.GOLD.dim_tempo AS dt
        ON fol.id_tempo = dt.id_tempo
    WHERE
        dt.ano = 2022
    GROUP BY
        dt.ano,
        dt.mes
)
SELECT
    ano,
    mes,
    obitos_mes,
    LAG(obitos_mes) OVER (ORDER BY ano, mes) AS obitos_mes_anterior,
    (obitos_mes - LAG(obitos_mes) OVER (ORDER BY ano, mes)) * 100.0 / LAG(obitos_mes) OVER (ORDER BY ano, mes) AS variacao_percentual
FROM saidas_mensais
ORDER BY
    ano,
    mes;


Insight: Esta análise mostra a variação percentual mensal de óbitos confirmados por COVID em 2022. É um indicador-chave para monitorar o impacto da pandemia e a eficácia das medidas de saúde pública ao longo do tempo.
Exemplo 3: Top 5 hospitais com maior taxa de altas confirmadas em 2021.
WITH hospital_metrics AS (
    SELECT
        dc.nm_estabelecimento,
        SUM(fol.saida_confirmada_altas) AS total_altas_confirmadas,
        SUM(fol.quantidade_leitos_ocupados) AS total_ocupacao
    FROM COVID19.GOLD.fact_ocupacao_leitos AS fol
    JOIN COVID19.GOLD.dim_cnes AS dc
        ON fol.id_cnes = dc.id_cnes
    JOIN COVID19.GOLD.dim_tempo AS dt
        ON fol.id_tempo = dt.id_tempo
    WHERE
        dt.ano = 2021
        AND fol.quantidade_leitos_ocupados IS NOT NULL
        AND fol.quantidade_leitos_ocupados > 0
    GROUP BY
        dc.nm_estabelecimento
)
SELECT
    nm_estabelecimento,
    total_altas_confirmadas,
    total_ocupacao,
    total_altas_confirmadas * 100.0 / total_ocupacao AS taxa_alta_percentual
FROM hospital_metrics
WHERE
    total_ocupacao > 0
ORDER BY
    taxa_alta_percentual DESC
LIMIT 5;


Insight: Esta consulta identifica os cinco hospitais com a maior taxa de altas confirmadas em 2021. Essa informação é vital para entender a eficiência e o sucesso de tratamentos em diferentes unidades de saúde, permitindo a identificação de melhores práticas.
9. Link para o dbt Docs gerado
(https://xk395.us1.dbt.com/accounts/70471823483161/develop/70471824053319/docs/index.html#!/overview/dbt_utils)

