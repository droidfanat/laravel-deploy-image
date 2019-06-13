#!/bin/bash

#############################################################################################################
###                                                                                                       ###
###                                                                                                       ###
###                                                                                                       ###
#############################################################################################################

backup_dir="./sql-backup"
sql_file="backup-sql.sql"
file_time=$((60 * 60 * 24))


file_check(){
   if [ ! -f "$backup_dir/$sql_file" ]; then
   echo "sql backupe file not found.";
   return 1;
   fi
}

file_time_check(){
  file_time=$(stat --format='%Y' "$backup_dir/$sql_file")
  current_time=$(date +%s)
  if ((file_time < (current_time-($file_time)))); then
    echo "SQL is older than 1 days"
    return 0
  fi
    return 1
}

db_backup(){
    echo "SQL backupe process ..."

    posgresql="pgsql"
    mysql="mysql"

    database_tupe=$(docker-compose exec -T php-fpm sh -c 'echo $DB_CONNECTION')
    database=$(docker-compose exec -T php-fpm sh -c 'echo $DB_DATABASE')
    dbuser=$(docker-compose exec -T php-fpm sh -c 'echo $DB_USERNAME')
    dbpassword=$(docker-compose exec -T php-fpm sh -c 'echo $DB_PASSWORD')

    echo driver type  $database_tupe

    if [[ "$database_tupe" == "$posgresql" ]]; then
        MYDB=$(echo -e "postgresql://$dbuser:$dbpassword@pgsql:5432/$database") > $backup_dir/$sql_file
        docker-compose exec -T pgsql pg_dump --dbname=$MYDB
        echo sql backupe finish $(head $backup_dir/$sql_file)

    elif [[ "$database_tupe" == "$mysql" ]]; then
        docker-compose exec -T mysql /usr/bin/mysqldump -u $dbuser --password=$dbpassword $database > $backup_dir/$sql_file
        echo sql backupe finish $(head $backup_dir/$sql_file)
    fi

}


if [ ! -d "$backup_dir" ]; then
    mkdir $backup_dir
fi


if (file_check); then
    if (file_time_check); then
       db_backup
    else
       echo "SQL backup did made less than one day"
    fi
else
       db_backup
fi
