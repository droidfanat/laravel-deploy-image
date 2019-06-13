#!/usr/bin/env sh
set -e

SERVER_CONFIG_PATH="${SERVER_CONFIG_PATH:-/etc/nginx/nginx.conf}";
FPM_CONFIG_PATH="${FPM_CONFIG_PATH:-/usr/local/etc/php-fpm.conf}";
FPM_USER="${FPM_USER:-root}";
FPM_GROUP="${FPM_GROUP:-root}";
FPM_PORT="${FPM_PORT:-9000}";
FPM_HOST="${FPM_HOST:-php-fpm}";
FPM_UPSTREAM_PARAMS="${FPM_UPSTREAM_PARAMS:-max_fails=3 fail_timeout=30s}";
ADDITIONAL_FPM_HOSTS="${ADDITIONAL_FPM_HOSTS:-# Additional fpm hosts not passed}";
NGINX_USER_NAME="$(getent passwd  "$FPM_USER" | cut -d: -f1)";
ROOT_DIR="${ROOT_DIR:-/app/public/}";
APP_BASE_URL="${APP_BASE_URL:-http://myapp.com/}";
NGINX_DOMAIN_NAME="${DOMAIN_NAME:-locallhost}"


sed -i "s#%FPM_PORT%#${FPM_PORT}#g" "$FPM_CONFIG_PATH";
sed -i "s#%FPM_USER%#${FPM_USER}#g" "$FPM_CONFIG_PATH";
sed -i "s#%FPM_GROUP%#${FPM_GROUP}#g" "$FPM_CONFIG_PATH";


sed -i "s#%FPM_PORT%#${FPM_PORT}#g" "$SERVER_CONFIG_PATH";
sed -i "s#%FPM_HOST%#${FPM_HOST}#g" "$SERVER_CONFIG_PATH";
sed -i "s#%FPM_UPSTREAM_PARAMS%#${FPM_UPSTREAM_PARAMS}#g" "$SERVER_CONFIG_PATH";
sed -i "s#%ROOT_DIR%#${ROOT_DIR}#g" "$SERVER_CONFIG_PATH";
sed -i "s#%APP_BASE_URL%#${APP_BASE_URL}#g" "$SERVER_CONFIG_PATH";
sed -i "s^%ADDITIONAL_FPM_HOSTS%^${ADDITIONAL_FPM_HOSTS}^g" "$SERVER_CONFIG_PATH";
sed -i -e "s/user.*/user ${NGINX_USER_NAME}\;/" "$SERVER_CONFIG_PATH";
sed -i -e "s|example.com|${NGINX_DOMAIN_NAME}|g" "$SERVER_CONFIG_PATH";


php-fpm -D -d "opcache.enable=0" -d "display_startup_errors=On" -d "display_errors=On" -d "error_reporting=E_ALL";
/usr/sbin/nginx;

exec "$@";