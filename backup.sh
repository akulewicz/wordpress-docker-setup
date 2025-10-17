#!/bin/bash

set -euo pipefail

source .env

site_dir="$PWD"
backup_dir="$site_dir/backup"
db_file="$site_dir/backup_$(date +%F).sql"
backup_file="${backup_dir}/backup_$(date +%F).tar.gz"

echo "===> Rozpoczynam backup bazy danych"

docker exec "$PROJECT_NAME"-db mariadb-dump -u root -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE" > "$db_file"

echo "===> Rozpoczynam tworzenie backupu: ${backup_file}"

if [ ! -d "$backup_dir" ]
then
    echo "===> Tworzę katalog backupu: $backup_dir"
    mkdir -p "$backup_dir"
fi

echo "===> Tworzę archiwum z backupem. Może to zająć dłuższą chwilę..."
if tar -czf "$backup_file" -C "$site_dir" --exclude="db" --exclude="backup" .
then
    echo "===> Backup zakończony pomyślnie"
else
    echo "===> Wystąpił błąd. Backup nie został utworzony"
    rm -f "$db_file"
    exit 1
fi

rm -f "$db_file"