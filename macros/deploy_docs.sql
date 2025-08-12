{% macro deploy_docs() %}
  {{ log("Running deploy_docs macro", info=True) }}

  {# 1. Comando principal do dbt para rodar o pipeline e gerar a documentação. #}
  {{ dbt_utils.run_shell_command(command="dbt build --full-refresh && dbt docs generate") }}

  {# 2. Configura o git com seu email e nome (opcional, mas boa prática). #}
  {{ dbt_utils.run_shell_command(command="git config user.email 'alissonmontijo@gmail.com'") }}
  {{ dbt_utils.run_shell_command(command="git config user.name 'adsmbr'") }}

  {# 3. Adiciona todos os arquivos da documentação na pasta 'target'. #}
  {{ dbt_utils.run_shell_command(command="git add target/") }}
  {{ dbt_utils.run_shell_command(command="git commit -m 'feat: Generate dbt docs'") }}

  {# 4. Usa o token de acesso para fazer um push forçado para a branch gh-pages. #}
  {{ dbt_utils.run_shell_command(command="git push -f https://DBT_GITHUB_TOKEN:" + env_var('DBT_GITHUB_TOKEN') + "@github.com/adsmbr/DESAFIO-FINAL-TRIGGO-AI.git gh-pages") }}

  {{ log("Deploy da documentação concluído.", info=True) }}
{% endmacro %}
