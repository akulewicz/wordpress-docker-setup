#!/bin/bash

set -euo pipefail

source .env

site_dir="$PWD"
backup_dir="$site_dir/backup"
db_file="$site_dir/backup_$(date +%F).sql"
backup_file="${backup_dir}/backup_$(date +%F).tar.gz"

log() {
    echo "===> $1"
}

cleanup() {
    rm -f "$db_file"
    log "Usunięto tymczasowy plik bazy danych"
}

create_backup_dir() {
    if [ ! -d "$backup_dir" ]
    then
        log "Tworzę katalog backupu: $backup_dir"
        mkdir -p "$backup_dir"
    fi
}

create_backup_database() {
    log "Rozpoczynam backup bazy danych"
    docker exec "$PROJECT_NAME"-db mariadb-dump \
        -u root -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE" > "$db_file"
}

create_archive() {
    log "Rozpoczynam tworzenie backupu: ${backup_file}"
    log "Tworzę archiwum z backupem. Może to zająć dłuższą chwilę..."
    if tar -czf "$backup_file" -C "$site_dir" --exclude="db" --exclude="backup" .
    then
        log "Backup zakończony pomyślnie"
    else
        log "Wystąpił błąd. Backup nie został utworzony"
        cleanup
        exit 1
    fi
}

main() {
    create_backup_dir
    create_backup_database
    create_archive
    cleanup
}

main




