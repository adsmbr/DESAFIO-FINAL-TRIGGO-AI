# deploy_docs.sh
dbt build --full-refresh
dbt docs generate
git config user.email "alissonmontijo@gmail.com"
git config user.name "adsmbr"
git add target/
git commit -m "feat: Generate dbt docs"
git push -f https://DBT_GITHUB_TOKEN:${DBT_GITHUB_TOKEN}@github.com/adsmbr/DESAFIO-FINAL-TRIGGO-AI.git gh-pages