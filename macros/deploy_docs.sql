{% macro deploy_docs() %}
  {{ log("Iniciando o deploy da documentação para o GitHub Pages...", info=True) }}

  {# Passo 1: Gerar os artefatos da documentação do dbt.
     CORREÇÃO: Usando 'dbt_utils.run_shell_command' em vez de 'run_query'. #}
  {% do dbt_utils.run_shell_command('dbt docs generate') %}
  {{ log("-> Documentação gerada com sucesso.", info=True) }}

  {# Passo 2: Configurar as credenciais do Git para o commit. #}
  {% do dbt_utils.run_shell_command('git config --global user.email "alissonmontijo@gmail.com"') %}
  {% do dbt_utils.run_shell_command('git config --global user.name "adsmbr"') %}
  {{ log("-> Configuração de identidade do Git concluída.", info=True) }}

  {# Passo 3: Criar uma branch temporária para o deploy. #}
  {% do dbt_utils.run_shell_command('git checkout -b gh-pages-temp') %}
  {{ log("-> Branch temporária 'gh-pages-temp' criada.", info=True) }}

  {# Passo 4: Adicionar a pasta 'target' e fazer o commit. #}
  {% do dbt_utils.run_shell_command('git add target/') %}
  {% do dbt_utils.run_shell_command('git commit -m "feat(docs): Atualiza documentação do dbt via dbt Cloud" --allow-empty') %}
  {{ log("-> Commit da documentação realizado.", info=True) }}

  {# Passo 5: Fazer o push forçado para a branch 'gh-pages' do seu repositório. #}
  {% set repo_url = 'https://' ~ env_var('DBT_GITHUB_TOKEN' ) ~ '@github.com/adsmbr/DESAFIO-FINAL-TRIGGO-AI.git' %}
  {% do dbt_utils.run_shell_command('git push --force ' ~ repo_url ~ ' gh-pages-temp:gh-pages') %}

  {{ log("✅ Deploy da documentação no GitHub Pages concluído com sucesso!", info=True) }}

{% endmacro %}
