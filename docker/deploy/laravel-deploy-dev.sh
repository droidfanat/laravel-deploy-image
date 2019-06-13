#!/bin/bash

###################### After deploy script ###############

WORK_DIR='/app'

cd $WORK_DIR || return 1

################### Fix storage permissions ###############

# Create dirs if not exist

chown -R ${FPM_USER}:${FPM_USER} storage

if  [ ! -d storage/framework/sessions ]; then
    mkdir -p storage/framework/sessions
fi

if  [ ! -d storage/framework/views ]; then
    mkdir -p storage/framework/views
fi

if  [ ! -d storage/framework/cache ]; then
    mkdir -p storage/framework/cache
fi

chown -R ${FPM_USER}:${FPM_USER} storage

if [ -L public/storage ]; then unlink public/storage; fi

php artisan storage:link

###################### Disallow robots only dev ################

echo -e "User-agent: * \nDisallow: /" > public/robots.txt

touch public/sitemap.xml && chmod 777 public/sitemap.xml


migrate_only() {
###################### After deploy tasks ################
php artisan migrate --force
php artisan view:clear
artisan cache:clear
}

ferst_deploy() {
###################### After deploy tasks ################
php artisan migrate:fresh --seed
php artisan view:clear
artisan cache:clear
}


for i in "$@"
do
case $i in
    -f*|--fdeploy)
    echo "first deploy fresh db migrate end seeds" 
    ferst_deploy
    shift 
    ;;
    -m|--migrate*)
    echo "migrate only"
    migrate_only    
    shift 
    ;;
esac
done