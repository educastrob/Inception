#!/bin/bash

DATADIR="/var/lib/mysql"
chown -R mysql:mysql "$DATADIR"

fresh=0
if [ ! -d "$DATADIR/mysql" ]; then
  echo "Inicializando data directory do MariaDB..."
  mariadb-install-db --user=mysql --datadir="$DATADIR" --auth-root-authentication-method=normal
  fresh=1
fi

echo "Iniciando mysqld temporário..."
mysqld_safe --datadir="$DATADIR" &
MYSQLD_PID=$!

# Espera até o servidor MariaDB estar disponível
until mariadb-admin ping --silent; do
  sleep 1
done

# Primeira vez, configura a senha do root
if [ "$fresh" -eq 1 ]; then
  mariadb -u root <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
SQL
fi

mariadb -u"${MARIADB_ROOT}" -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};"
mariadb -u"${MARIADB_ROOT}" -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_USER_PASSWORD}';"
mariadb -u"${MARIADB_ROOT}" -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'localhost' IDENTIFIED BY '${MARIADB_USER_PASSWORD}';"
mariadb -u"${MARIADB_ROOT}" -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';"
mariadb -u"${MARIADB_ROOT}" -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'localhost';"
mariadb -u"${MARIADB_ROOT}" -p"${MARIADB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" <<-SQL
  ALTER USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
  FLUSH PRIVILEGES;
SQL

# Encerra o servidor mysqld temporário
mariadb-admin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown || mariadb-admin -u root shutdown || true
wait "$MYSQLD_PID" || true

exec mariadbd-safe