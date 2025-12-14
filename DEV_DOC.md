# Documentação de Desenvolvimento - Inception

## Índice

1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Configuração do Ambiente](#configuração-do-ambiente)
4. [Arquitetura do Projeto](#arquitetura-do-projeto)
5. [Uso do Makefile](#uso-do-makefile)
6. [Comandos do Docker Compose](#comandos-do-docker-compose)
7. [Estrutura de Containers](#estrutura-de-containers)
8. [Persistência de Dados](#persistência-de-dados)
9. [Rede e Comunicação](#rede-e-comunicação)
10. [Variáveis de Ambiente](#variáveis-de-ambiente)
11. [Desenvolvimento e Debugging](#desenvolvimento-e-debugging)
12. [Boas Práticas](#boas-práticas)

---

## Visão Geral

O projeto Inception implementa uma infraestrutura de microserviços usando Docker Compose, seguindo os requisitos do projeto da 42. A arquitetura consiste em três containers principais:

- **NGINX**: Servidor web reverso com SSL/TLS
- **WordPress**: CMS rodando com PHP-FPM
- **MariaDB**: Sistema de gerenciamento de banco de dados

Cada serviço é construído a partir de um Dockerfile personalizado e roda em um container isolado, comunicando-se através de uma rede Docker privada.

## Pré-requisitos

### Software Necessário

- **Docker Engine**: >= 20.10
- **Docker Compose**: >= 2.0
- **Make**: Para automação de comandos
- **Git**: Para controle de versão
- **curl**: Para download de arquivos e testes
- **Openssl**: Para geração de certificados SSL (opcional)

### Conhecimentos Recomendados

- Conceitos de Docker e containerização
- Docker Compose e orquestração de containers
- Redes Docker (bridge networks)
- Volumes Docker para persistência
- Configuração de servidores web (NGINX)
- PHP-FPM e WordPress
- MariaDB/MySQL
- Shell scripting (Bash)

### Verificar Instalação

```bash
docker --version
docker compose version
make --version
```

## Configuração do Ambiente

### 1. Clone o Repositório

```bash
git clone <url-do-repositorio>
cd Inception
```

### 2. Estrutura de Diretórios

```
Inception/
├── Makefile                          # Automação de tarefas
├── README.md                         # Documentação principal
├── USER_DOC.md                       # Documentação do usuário
├── DEV_DOC.md                        # Este arquivo
└── srcs/
    ├── docker-compose.yml            # Orquestração dos serviços
    ├── .env                          # Variáveis de ambiente (não versionado)
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile            # Imagem do MariaDB
        │   ├── conf/                 # Configurações customizadas
        │   └── tools/
        │       └── init.sh           # Script de inicialização
        ├── nginx/
        │   ├── Dockerfile            # Imagem do NGINX
        │   ├── conf/
        │   │   └── nginx.conf        # Configuração do NGINX
        │   └── tools/                # Scripts auxiliares
        └── wordpress/
            ├── Dockerfile            # Imagem do WordPress
            ├── conf/                 # Configurações do PHP/WordPress
            └── tools/
                └── setup.sh          # Script de setup do WordPress
```

### 3. Configurar Variáveis de Ambiente

O arquivo `.env` é baixado automaticamente pelo Makefile, mas você pode criá-lo manualmente:

```bash
cd srcs
cat > .env << 'EOF'
# Domain
DOMAIN_NAME=edcastro.42.fr

# MariaDB Configuration
MARIADB_HOST=mariadb
MARIADB_ROOT=root
MARIADB_ROOT_PASSWORD=root_secure_password
MARIADB_DATABASE=wordpress
MARIADB_USER=wp_user
MARIADB_PASSWORD=wp_secure_password

# WordPress Configuration
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=admin_secure_password
WP_ADMIN_EMAIL=admin@edcastro.42.fr
WP_USER=user
WP_USER_PASSWORD=user_secure_password
WP_USER_EMAIL=user@edcastro.42.fr
EOF
```

**IMPORTANTE**: Nunca versione o arquivo `.env` com credenciais reais!

## Arquitetura do Projeto

### Diagrama de Comunicação

```
┌─────────────────┐
│   Navegador     │
└────────┬────────┘
         │ HTTPS (443)
         ▼
┌─────────────────┐
│  NGINX (Alpine) │
│  TLSv1.2/1.3    │
└────────┬────────┘
         │ FastCGI (9000)
         ▼
┌─────────────────┐
│ WordPress       │
│ PHP-FPM         │
└────────┬────────┘
         │ MySQL Protocol (3306)
         ▼
┌─────────────────┐
│ MariaDB         │
│ Database        │
└─────────────────┘
```

### Fluxo de Inicialização

1. **MariaDB** inicia primeiro (healthcheck)
2. **WordPress** aguarda MariaDB estar saudável
3. **NGINX** aguarda WordPress estar pronto
4. Sistema completo está operacional

## Uso do Makefile

O Makefile automatiza tarefas comuns de desenvolvimento e operação.

### Comandos Disponíveis

#### `make` ou `make build`
Construir e iniciar todo o ambiente.

```bash
make
```

**O que faz**:
- Baixa o arquivo `.env` se não existir
- Cria diretórios de volumes: `/home/edcastro/data/mariadb` e `/home/edcastro/data/wordpress`
- Adiciona `edcastro.42.fr` ao `/etc/hosts`
- Executa `docker compose up --build -d`

#### `make install`
Instalar Docker e Docker Compose.

```bash
make install
```

**O que faz**:
- Baixa e executa o script de instalação oficial do Docker
- Adiciona o usuário atual ao grupo docker
- Configura permissões sudo para volumes

#### `make down`
Parar containers sem remover volumes.

```bash
make down
```

#### `make kill`
Forçar parada de todos os containers.

```bash
make kill
```

#### `make clean`
Remover tudo (containers, volumes, dados).

```bash
make clean
```

**ATENÇÃO**: Remove todos os dados persistidos!

#### `make restart`
Limpar e reconstruir tudo.

```bash
make restart
```

Equivalente a: `make clean && make build`

### Variáveis do Makefile

```makefile
LOGIN := edcastro
DOMAIN_NAME := $(LOGIN).42.fr
PATH_TO_VOLUME := /home/$(LOGIN)/data
DOCKER_COMPOSE = sudo docker compose -f ./srcs/docker-compose.yml
```

Para personalizar, edite essas variáveis no início do Makefile.

## Comandos do Docker Compose

### Comando Base

```bash
sudo docker compose -f ./srcs/docker-compose.yml [COMANDO]
```

### Comandos Úteis

#### Iniciar serviços
```bash
sudo docker compose -f ./srcs/docker-compose.yml up -d
```

#### Parar serviços
```bash
sudo docker compose -f ./srcs/docker-compose.yml down
```

#### Ver logs
```bash
# Todos os serviços
sudo docker compose -f ./srcs/docker-compose.yml logs -f

# Serviço específico
sudo docker compose -f ./srcs/docker-compose.yml logs -f nginx
sudo docker compose -f ./srcs/docker-compose.yml logs -f wordpress
sudo docker compose -f ./srcs/docker-compose.yml logs -f mariadb
```

#### Reconstruir um serviço específico
```bash
sudo docker compose -f ./srcs/docker-compose.yml up -d --build nginx
```

#### Executar comandos em um container
```bash
sudo docker compose -f ./srcs/docker-compose.yml exec mariadb bash
sudo docker compose -f ./srcs/docker-compose.yml exec wordpress sh
sudo docker compose -f ./srcs/docker-compose.yml exec nginx sh
```

#### Ver status dos serviços
```bash
sudo docker compose -f ./srcs/docker-compose.yml ps
```

## Estrutura de Containers

### Container NGINX

**Base**: Alpine Linux (penúltima versão estável)

**Portas Expostas**: 443 (HTTPS)

**Volumes**:
- `wordpress_data:/var/www/html` (compartilhado com WordPress)

**Configuração**:
- Certificado SSL auto-assinado
- TLSv1.2 e TLSv1.3
- FastCGI para comunicação com PHP-FPM
- Server block para `edcastro.42.fr`

**Healthcheck**: `curl -f https://edcastro.42.fr`

### Container WordPress

**Base**: Alpine Linux ou Debian (penúltima versão estável)

**Porta Exposta**: 9000 (FastCGI, apenas na rede interna)

**Volumes**:
- `wordpress_data:/var/www/html`

**Dependências**:
- MariaDB (deve estar saudável antes de iniciar)

**Configuração**:
- PHP-FPM
- WP-CLI para instalação automatizada
- Dois usuários WordPress (admin + user)

**Healthcheck**: Verificação de conectividade

### Container MariaDB

**Base**: Alpine Linux ou Debian (penúltima versão estável)

**Porta**: 3306 (apenas na rede interna, não exposta ao host)

**Volumes**:
- `mariadb_data:/var/lib/mysql`

**Configuração**:
- Banco de dados WordPress
- Usuário root + usuário WordPress
- Configurações otimizadas para WordPress

**Healthcheck**: `mysqladmin ping -h localhost`

## Persistência de Dados

### Tipos de Volumes

O projeto usa **bind mounts** para facilitar acesso aos dados:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/edcastro/data/mariadb
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/edcastro/data/wordpress
```

### Localização dos Dados

- **MariaDB**: `/home/edcastro/data/mariadb`
- **WordPress**: `/home/edcastro/data/wordpress`

### Backup dos Dados

#### Backup Manual

```bash
# Backup MariaDB
sudo docker exec mariadb mysqldump -u root -p wordpress > backup.sql

# Backup WordPress
sudo tar -czf wordpress_backup.tar.gz /home/edcastro/data/wordpress
```

#### Restauração

```bash
# Restaurar MariaDB
sudo docker exec -i mariadb mysql -u root -p wordpress < backup.sql

# Restaurar WordPress
sudo tar -xzf wordpress_backup.tar.gz -C /
```

### Permissões

Os volumes devem ter permissões adequadas:

```bash
sudo chown -R 999:999 /home/edcastro/data/mariadb
sudo chown -R www-data:www-data /home/edcastro/data/wordpress
```

## Rede e Comunicação

### Rede Docker

Nome: `inception_inception-network`
Tipo: `bridge`

### Resolução de Nomes

Os containers se comunicam usando seus nomes de serviço:

- `mariadb` → Container do banco de dados
- `wordpress` → Container do WordPress
- `nginx` → Container do NGINX

Exemplo de conexão do WordPress ao MariaDB:
```php
define('DB_HOST', 'mariadb:3306');
```

### Isolamento

A rede é isolada. Apenas a porta 443 do NGINX é exposta ao host.

### Inspecting Network

```bash
sudo docker network inspect inception_inception-network
```

## Variáveis de Ambiente

### Arquivo .env

Localizado em `./srcs/.env`, este arquivo contém todas as variáveis sensíveis.

### Uso no docker-compose.yml

```yaml
services:
  mariadb:
    env_file: .env
    environment:
      - MARIADB_HOST
      - MARIADB_ROOT
      - MARIADB_ROOT_PASSWORD
      # ...
```

### Acesso nos Scripts

```bash
#!/bin/bash
# Em init.sh ou setup.sh
echo "Database: $MARIADB_DATABASE"
echo "User: $MARIADB_USER"
```

### Variáveis Disponíveis

Veja a seção "Variáveis de Ambiente" em [USER_DOC.md](USER_DOC.md) para lista completa.

## Desenvolvimento e Debugging

### Acessar Shell de um Container

```bash
# MariaDB
sudo docker exec -it mariadb sh

# WordPress
sudo docker exec -it wordpress sh

# NGINX
sudo docker exec -it nginx sh
```

### Verificar Logs em Tempo Real

```bash
sudo docker compose -f ./srcs/docker-compose.yml logs -f
```

### Testar Conectividade entre Containers

```bash
# Do container WordPress, testar conexão com MariaDB
sudo docker exec wordpress ping mariadb

# Testar conexão MySQL
sudo docker exec wordpress mysql -h mariadb -u wp_user -p
```

### Verificar Processos

```bash
# Processos no container
sudo docker exec nginx ps aux
sudo docker exec wordpress ps aux
sudo docker exec mariadb ps aux
```

### Inspecionar Container

```bash
sudo docker inspect nginx
sudo docker inspect wordpress
sudo docker inspect mariadb
```

### Modificar Arquivos em Tempo Real

Como os volumes são bind mounts, você pode editar diretamente:

```bash
# Editar arquivo WordPress
sudo nano /home/edcastro/data/wordpress/wp-config.php

# Reiniciar para aplicar mudanças
sudo docker restart wordpress
```

### Debugging de SSL/TLS

```bash
# Testar certificado
openssl s_client -connect edcastro.42.fr:443

# Ver detalhes do certificado
sudo docker exec nginx openssl x509 -in /etc/nginx/ssl/nginx.crt -text
```

### Debugging do PHP-FPM

```bash
# Ver configuração PHP
sudo docker exec wordpress php -i

# Ver módulos carregados
sudo docker exec wordpress php -m

# Testar sintaxe de arquivo PHP
sudo docker exec wordpress php -l /var/www/html/wp-config.php
```

### Debugging do MariaDB

```bash
# Conectar ao MySQL
sudo docker exec -it mariadb mysql -u root -p

# Verificar bancos de dados
sudo docker exec mariadb mysql -u root -p -e "SHOW DATABASES;"

# Verificar usuários
sudo docker exec mariadb mysql -u root -p -e "SELECT user,host FROM mysql.user;"
```

## Boas Práticas

### Durante o Desenvolvimento

1. **Use branches Git** para features experimentais
2. **Teste mudanças incrementalmente** - não modifique tudo de uma vez
3. **Mantenha backups** antes de mudanças importantes
4. **Documente alterações** no código e nos Dockerfiles
5. **Use `.dockerignore`** para evitar arquivos desnecessários nas imagens

### Segurança

1. **Nunca versione** o arquivo `.env` com credenciais reais
2. **Use senhas fortes** em produção
3. **Mantenha imagens atualizadas** (Alpine/Debian)
4. **Execute containers como non-root** quando possível
5. **Limite recursos** (CPU/memória) em produção

### Performance

1. **Otimize camadas do Dockerfile** (ordem de COPY e RUN)
2. **Use cache do Docker** eficientemente
3. **Minimize tamanho das imagens** (multi-stage builds se necessário)
4. **Configure corretamente PHP-FPM** (número de workers)
5. **Ajuste configurações do MariaDB** para uso adequado de memória

### Docker Compose

1. **Use healthchecks** para garantir dependências
2. **Configure restart policies** (restart: always)
3. **Separe redes** quando necessário
4. **Use named volumes** ou bind mounts apropriadamente
5. **Documente configurações** com comentários

### Debugging

1. **Sempre verifique logs** primeiro
2. **Use `docker exec`** para investigar containers
3. **Teste mudanças isoladamente** (um serviço por vez)
4. **Mantenha um ambiente de teste** separado
5. **Use `docker compose down -v`** para limpar estado entre testes

---

## Recursos Adicionais

### Documentação Oficial

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Documentation](https://mariadb.org/documentation/)

### Comandos Docker Úteis

```bash
# Listar todas as imagens
docker images

# Remover imagens não usadas
docker image prune -a

# Ver uso de disco do Docker
docker system df

# Limpar tudo (cuidado!)
docker system prune -a --volumes

# Ver uso de recursos em tempo real
docker stats

# Exportar/importar imagem
docker save nginx > nginx.tar
docker load < nginx.tar
```

---

**Última atualização**: Dezembro 2025  
**Versão**: 1.0  
**Mantenedor**: edcastro
