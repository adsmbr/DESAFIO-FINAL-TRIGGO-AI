{% macro deploy_docs() %}
  {{ log("Iniciando o deploy da documentação...", info=True) }}

  {# Passo 1: Gera os artefatos da documentação. #}
  {% do run_query('dbt docs generate') %}
  {{ log("Documentação gerada com sucesso.", info=True) }}

  {# Passo 2: Configura as credenciais do Git para o commit. #}
  {% do dbt_utils.run_shell_command('git config --global user.email "alissonmontijo@gmail.com"') %}
  {% do dbt_utils.run_shell_command('git config --global user.name "adsmbr"') %}
  {{ log("Configuração do Git concluída.", info=True) }}

  {# Passo 3: Faz o checkout para uma branch temporária para isolar o processo. #}
  {% do dbt_utils.run_shell_command('git checkout -b gh-pages-temp') %}

  {# Passo 4: Adiciona a pasta 'target' (que contém a documentação) e faz o commit. #}
  {% do dbt_utils.run_shell_command('git add target/') %}
  {% do dbt_utils.run_shell_command('git commit -m "feat: Gerar documentação do dbt via dbt Cloud" --allow-empty') %}
  {{ log("Commit da documentação realizado.", info=True) }}

  {# Passo 5: Faz o push forçado para a branch 'gh-pages' do seu repositório. #}
  {% set repo_url = 'https://' ~ env_var('DBT_GITHUB_TOKEN' ) ~ '@github.com/adsmbr/DESAFIO-FINAL-TRIGGO-AI.git' %}
  {% do dbt_utils.run_shell_command('git push --force ' ~ repo_url ~ ' gh-pages-temp:gh-pages') %}

  {{ log("Deploy da documentação no GitHub Pages concluído com sucesso!", info=True) }}

{% endmacro %}
