-- macros/performance_utils.sql
-- Performance optimization utilities for COVID19 dbt project
-- These macros are OPTIONAL and only used when explicitly called

{% macro optimize_incremental_strategy() %}
  {#
    Macro para otimizar estratégia incremental baseada no volume de dados
    Uso: {{ optimize_incremental_strategy() }}
  #}
  
  {% if is_incremental() %}
    -- Estratégia otimizada para grandes volumes
    WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
    -- Adiciona filtro de data para performance
    AND data_notificacao >= (SELECT DATE_SUB(MAX(data_notificacao), INTERVAL 7 DAY) FROM {{ this }})
  {% else %}
    -- Full refresh - sem filtros
  {% endif %}
  
{% endmacro %}

{% macro get_performance_config(model_type='table') %}
  {#
    Retorna configurações otimizadas baseadas no tipo de modelo
    Uso: {{ config(get_performance_config('fact')) }}
  #}
  
  {% if model_type == 'fact' %}
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_fato',
    on_schema_change='sync_all_columns'
    {%- if target.name == 'prod' %}
    ,cluster_by=['id_tempo', 'id_localidade'],
    partition_by={'field': 'updated_at', 'data_type': 'timestamp'}
    {%- endif %}
    
  {% elif model_type == 'dimension' %}
    materialized='table'
    {%- if target.name == 'prod' %}
    ,cluster_by=['id_' + model_type]
    {%- endif %}
    
  {% elif model_type == 'staging' %}
    materialized='view'
    
  {% else %}
    materialized='table'
  {% endif %}
  
{% endmacro %}

{% macro log_performance_metrics(model_name) %}
  {#
    Log métricas de performance para monitoramento
    Uso: {{ log_performance_metrics(this.name) }}
  #}
  
  {% if execute %}
    {% set query %}
      SELECT 
        '{{ model_name }}' as model_name,
        COUNT(*) as row_count,
        CURRENT_TIMESTAMP() as measured_at
      FROM {{ this }}
    {% endset %}
    
    {% set results = run_query(query) %}
    {% if results %}
      {% for row in results %}
        {{ log("📊 Model: " ~ row[0] ~ " | Rows: " ~ row[1] ~ " | Time: " ~ row[2], info=true) }}
      {% endfor %}
    {% endif %}
  {% endif %}
  
{% endmacro %}