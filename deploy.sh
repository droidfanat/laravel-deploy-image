posgresql="pgsql"
mysql="mysql"
eval $(ssh-agent -s)
echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - > /dev/null
mkdir -p ~/.ssh
chmod 700 ~/.ssh
[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

ssh-keyscan ${SSH_HOST} >> ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts

echo "$ENV_VARIABLES" | base64 -d > .env 
source .env

cat /docker/template/docker-compose-${CI_COMMIT_REF_NAME}.yml > docker-compose.yml


sed -i -e "s|registry.example.com/group/user.*|$CI_REGISTRY_IMAGE:${CI_COMMIT_REF_NAME}|g" "docker-compose.yml"
sed -i -e "s|Host:example.com,www.example.com|Host:${DOMAIN},www.${DOMAIN}|g" "docker-compose.yml"
sed -i -e "s|domain.example.com|${DOMAIN}|g" "docker-compose.yml"
sed -i -e "s|redirect.regex=^http?://example.com|redirect.regex=^http?://${DOMAIN}|g" "docker-compose.yml"
sed -i -e "s|redirect.replacement=https://example.com|redirect.replacement=https://${DOMAIN}|g" "docker-compose.yml"



if [[ "${DB_CONNECTION}" == "$posgresql" ]]; then
    cat /docker/template/services/${DB_CONNECTION}.yml >> docker-compose.yml
    sed -i -e "s|seed-sql|${posgresql}|g" "docker-compose.yml"
    sed -i -e "s|POSTGRES_DB: pgsql_db|POSTGRES_DB: ${DB_DATABASE}|g" "docker-compose.yml"
    sed -i -e "s|POSTGRES_USER: pgsql_user|POSTGRES_USER: ${DB_USERNAME}|g" "docker-compose.yml"
    sed -i -e "s|POSTGRES_PASSWORD: pgsql_password|POSTGRES_PASSWORD: ${DB_PASSWORD}|g" "docker-compose.yml"

elif [[ "${DB_CONNECTION}" == "$mysql" ]]; then
    cat /docker/template/services/${DB_CONNECTION}.yml >> docker-compose.yml
    sed -i -e "s|seed-sql|${mysql}|g" "docker-compose.yml"
    sed -i -e "s|MYSQL_DATABASE: homestead|MYSQL_DATABASE: ${DB_DATABASE}|g" "docker-compose.yml"
    sed -i -e "s|MYSQL_USER: homestead|MYSQL_USER: ${DB_USERNAME}|g" "docker-compose.yml"
    sed -i -e "s|MYSQL_PASSWORD: secret|MYSQL_PASSWORD: ${DB_PASSWORD}|g" "docker-compose.yml"
fi

python /docker/bin/deploy.py


ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} "cd ${SERVER_PATH} && chmod +x sql-backup.sh && ./sql-backup.sh && docker-compose down "

scp -P ${SSH_PORT} /docker/deploy/sql-backup.sh .env docker-compose.yml ${SSH_USER}@${SSH_HOST}:${SERVER_PATH}

ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} "cd ${SERVER_PATH} && docker login -u "$CI_REGISTRY_USER" -p "$CI_JOB_TOKEN" "$CI_REGISTRY" &&docker-compose pull --quiet"

echo ${DEPLOY_CLEAN}

ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} "cd ${SERVER_PATH} && export UID=\${UID} && export GID=\${GID}   && 
docker-compose up -d  && 
if [[ ! -f deploy.lock || \"${DEPLOY_CLEAN}\" == \"YES\" ]];  then 
   docker-compose exec -T php-fpm /deploy/laravel-deploy-${CI_COMMIT_REF_NAME}.sh -f;
   touch deploy.lock;
else 
   docker-compose exec -T php-fpm /deploy/laravel-deploy-${CI_COMMIT_REF_NAME}.sh -m && 
;fi 
docker-compose exec -T php-fpm docker/deploy/after-deploy-${CI_COMMIT_REF_NAME}.sh
" 

exit 0