SSH_PORT=53126
SSH_USER=devserver
SSH_HOST=116.202.66.227
SERVER_PATH=/home/devserver/testlaravel.dev.myapp.com.ua
CI_COMMIT_REF_NAME=dev
DEPLOY_CLEAN="YES"

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