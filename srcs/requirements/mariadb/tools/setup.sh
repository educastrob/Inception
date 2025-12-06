#!/bin/bash
set -e

DATADIR="/var/lib/mysql"

echo "=== Setup MariaDB ==="

# Permissões
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
chmod 777 /var/run/mysqld

# Inicializar apenas na primeira vez
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Primeira inicialização..."
    
    mysql_install_db --user=mysql --datadir="$DATADIR"
    
    # Iniciar MariaDB temporariamente em background
    echo "Iniciando MariaDB temporariamente para configuração..."
    mysqld --user=mysql --datadir="$DATADIR" --skip-networking &
    MYSQLD_PID=$!
    
    # Aguardar MariaDB ficar pronto
    sleep 3
    for i in {1..30}; do
        if mysqladmin ping >/dev/null 2>&1; then
            echo "✓ MariaDB está pronto!"
            break
        fi
        echo "Tentativa $i/30..."
        sleep 1
    done
    
    # Configurar usuários via pipe
    echo "Configurando database e usuários..."
    mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
DELETE FROM mysql.user WHERE user='';
FLUSH PRIVILEGES;
EOF
    
    echo "✓ Setup concluído!"
    
    # Parar MariaDB temporário
    mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
    wait $MYSQLD_PID 2>/dev/null || true
    
    sleep 2
fi

echo ""
echo "=== Iniciando MariaDB em foreground ==="
exec mysqld --user=mysql --console