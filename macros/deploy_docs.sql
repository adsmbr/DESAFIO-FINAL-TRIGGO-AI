{% macro deploy_docs() %}
  {{ log("Iniciando o deploy da documentação...", info=True) }}

  {# Executa o pipeline completo do dbt e a geração da documentação #}
  {% do run_shell_command('dbt build --full-refresh') %}
  {% do run_shell_command('dbt docs generate') %}

  {# Configura as credenciais Git no ambiente de execução #}
  {% do run_shell_command('git config user.email "alissonmontijo@gmail.com"') %}
  {% do run_shell_command('git config user.name "adsmbr"') %}

  {# Adiciona os arquivos da documentação e faz o commit #}
  {% do run_shell_command('git add target/') %}
  {% do run_shell_command('git commit -m "feat: Gerar documentação do dbt"') %}

  {# Faz o push para a branch gh-pages usando o token de ambiente #}
  {% do run_shell_command('git push -f https://DBT_GITHUB_TOKEN:' ~ env_var('DBT_GITHUB_TOKEN') ~ '@github.com/adsmbr/DESAFIO-FINAL-TRIGGO-AI.git gh-pages') %}

  {{ log("Deploy da documentação concluído com sucesso!", info=True) }}
{% endmacro %}

{% macro run_shell_command(command) %}
  {{ log('Executando comando: ' ~ command, info=True) }}
  {{ dbt_utils.run_shell_command(command=command) }}
{% endmacro %}
