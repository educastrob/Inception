# Documentação do Usuário - Inception

## Índice

1. [Introdução](#introdução)
2. [Requisitos do Sistema](#requisitos-do-sistema)
3. [Instalação](#instalação)
4. [Iniciar o Stack](#iniciar-o-stack)
5. [Parar o Stack](#parar-o-stack)
6. [Acessar o Site](#acessar-o-site)
7. [Painel de Administração](#painel-de-administração)
8. [Gerenciamento de Credenciais](#gerenciamento-de-credenciais)
9. [Verificações Básicas](#verificações-básicas)
10. [Solução de Problemas](#solução-de-problemas)

---

## Introdução

Este documento fornece instruções de uso do projeto Inception para usuários finais e administradores. O Inception é uma infraestrutura baseada em Docker que fornece um ambiente WordPress completo com NGINX e MariaDB.

## Requisitos do Sistema

Antes de começar, certifique-se de que seu sistema atende aos seguintes requisitos:

- **Sistema Operacional**: Linux (Ubuntu, Debian, Fedora, etc.)
- **RAM**: Mínimo 2GB (4GB recomendado)
- **Espaço em Disco**: Pelo menos 5GB livres
- **Porta 443**: Deve estar disponível (não pode estar em uso por outro serviço)
- **Permissões**: Acesso sudo ao sistema
- **Docker**: Versão 20.10 ou superior
- **Docker Compose**: Versão 2.0 ou superior

## Instalação

### Passo 1: Obter o Projeto

Clone o repositório para sua máquina:

```bash
git clone <url-do-repositorio>
cd Inception
```

### Passo 2: Instalar o Docker (se necessário)

Se você ainda não tem o Docker instalado, execute:

```bash
make install
```

**Nota**: Após a instalação, pode ser necessário fazer logout e login novamente para que as permissões do grupo Docker sejam aplicadas.

### Passo 3: Verificar a Instalação

Verifique se o Docker foi instalado corretamente:

```bash
docker --version
docker compose version
```

## Iniciar o Stack

Para iniciar todo o ambiente (NGINX, WordPress e MariaDB):

```bash
make
```

Ou de forma equivalente:

```bash
make build
```

Este comando irá:
1. Baixar o arquivo `.env` com as variáveis de ambiente (se não existir)
2. Criar os diretórios de volumes para persistência de dados
3. Adicionar `edcastro.42.fr` ao arquivo `/etc/hosts`
4. Construir as imagens Docker personalizadas
5. Iniciar todos os containers

**Tempo estimado**: A primeira execução pode levar de 3 a 10 minutos, dependendo da velocidade da sua conexão de internet.

### Verificar o Status

Após iniciar, você pode verificar se todos os containers estão rodando:

```bash
sudo docker ps
```

Você deve ver três containers em execução:
- `nginx`
- `wordpress`
- `mariadb`

## Parar o Stack

### Parada Normal

Para parar os containers mantendo os dados e configurações:

```bash
make down
```

Os containers serão parados, mas os volumes de dados permanecerão intactos.

### Parada Forçada

Para forçar a parada imediata de todos os containers:

```bash
make kill
```

**Atenção**: Use este comando apenas em casos de emergência, pois pode causar perda de dados não salvos.

## Acessar o Site

### URL Principal

Após iniciar o stack, acesse o site em seu navegador:

```
https://edcastro.42.fr
```

### Aviso de Certificado

Como o certificado SSL é auto-assinado, seu navegador mostrará um aviso de segurança na primeira vez. Isso é esperado e seguro em um ambiente de desenvolvimento.

**Como proceder**:

- **Chrome/Edge**: Clique em "Advanced" (Avançado) → "Proceed to edcastro.42.fr"
- **Firefox**: Clique em "Advanced" (Avançado) → "Accept the Risk and Continue"

## Painel de Administração

### Acessar o WordPress Admin

Para acessar o painel administrativo do WordPress:

1. Navegue até: `https://edcastro.42.fr/wp-admin`
2. Faça login com as credenciais de administrador (veja seção [Gerenciamento de Credenciais](#gerenciamento-de-credenciais))

### Funcionalidades Disponíveis

No painel administrativo você pode:

- Criar e editar páginas e posts
- Gerenciar usuários
- Instalar e configurar temas
- Adicionar plugins
- Modificar configurações do site
- Gerenciar mídia (imagens, vídeos, documentos)

## Gerenciamento de Credenciais

### Localização das Credenciais

Todas as credenciais sensíveis são armazenadas no arquivo `.env` localizado em:

```
./srcs/.env
```

### Credenciais Padrão

O arquivo `.env` contém as seguintes variáveis:

#### Banco de Dados MariaDB
- `MARIADB_HOST`: Host do banco de dados (geralmente "mariadb")
- `MARIADB_ROOT`: Usuário root do banco
- `MARIADB_ROOT_PASSWORD`: Senha do usuário root
- `MARIADB_DATABASE`: Nome do banco de dados do WordPress
- `MARIADB_USER`: Usuário do banco de dados do WordPress
- `MARIADB_PASSWORD`: Senha do usuário do banco

#### WordPress
- `WP_ADMIN_USER`: Nome do usuário administrador
- `WP_ADMIN_PASSWORD`: Senha do administrador
- `WP_ADMIN_EMAIL`: Email do administrador
- `WP_USER`: Nome de um usuário adicional
- `WP_USER_PASSWORD`: Senha do usuário adicional
- `WP_USER_EMAIL`: Email do usuário adicional

#### Domínio
- `DOMAIN_NAME`: Nome do domínio (edcastro.42.fr)

### Alterar Credenciais

**IMPORTANTE**: Se você deseja alterar as credenciais:

1. **Antes da primeira execução**: Edite o arquivo `./srcs/.env`
2. **Após a primeira execução**: 
   ```bash
   make clean  # Remove todos os dados
   # Edite o arquivo .env
   make        # Reconstrói com as novas credenciais
   ```

**Atenção**: O comando `make clean` **remove todos os dados**, incluindo posts, páginas e uploads do WordPress!

## Verificações Básicas

### 1. Verificar se os Containers Estão Rodando

```bash
sudo docker ps
```

Todos os três containers devem aparecer com status "Up".

### 2. Verificar Logs dos Containers

Para ver os logs de um container específico:

```bash
# Logs do NGINX
sudo docker logs nginx

# Logs do WordPress
sudo docker logs wordpress

# Logs do MariaDB
sudo docker logs mariadb
```

### 3. Verificar a Conectividade

Teste se o site está respondendo:

```bash
curl -k https://edcastro.42.fr
```

Você deve receber o HTML da página inicial do WordPress.

### 4. Verificar o Banco de Dados

Para verificar se o MariaDB está funcionando:

```bash
sudo docker exec mariadb mysqladmin ping -h localhost
```

Deve retornar: "mysqld is alive"

### 5. Verificar os Volumes

Para ver os volumes criados e seu tamanho:

```bash
sudo docker volume ls
sudo du -sh /home/edcastro/data/*
```

### 6. Verificar a Rede

Para ver a rede Docker criada:

```bash
sudo docker network ls | grep inception
sudo docker network inspect inception_inception-network
```

## Solução de Problemas

### Problema: Porta 443 em uso

**Sintoma**: Erro ao iniciar o NGINX dizendo que a porta 443 está em uso.

**Solução**: 
```bash
# Identifique qual processo está usando a porta
sudo lsof -i :443

# Pare o serviço conflitante (exemplo: Apache)
sudo systemctl stop apache2
```

### Problema: Containers não iniciam

**Sintoma**: Containers param logo após iniciar.

**Solução**:
```bash
# Verifique os logs
sudo docker logs nginx
sudo docker logs wordpress
sudo docker logs mariadb

# Tente reiniciar
make restart
```

### Problema: Site não carrega

**Sintoma**: Navegador não consegue acessar https://edcastro.42.fr

**Solução**:
1. Verifique se o domínio está no `/etc/hosts`:
   ```bash
   cat /etc/hosts | grep edcastro.42.fr
   ```
2. Verifique se os containers estão rodando:
   ```bash
   sudo docker ps
   ```
3. Limpe o cache do navegador e tente novamente

### Problema: Erro de permissão nos volumes

**Sintoma**: WordPress não consegue fazer upload de arquivos.

**Solução**:
```bash
sudo chmod -R 755 /home/edcastro/data/wordpress
sudo chown -R www-data:www-data /home/edcastro/data/wordpress
```

### Problema: Banco de dados não conecta

**Sintoma**: WordPress mostra erro de conexão com o banco de dados.

**Solução**:
```bash
# Reinicie apenas o MariaDB
sudo docker restart mariadb

# Aguarde 30 segundos e reinicie o WordPress
sudo docker restart wordpress
```

### Remover Tudo e Recomeçar

Se nada funcionar, você pode remover tudo e começar do zero:

```bash
make clean
make
```

**Atenção**: Este comando remove **TODOS os dados**, incluindo posts e configurações do WordPress!

---

## Suporte

Para problemas técnicos ou questões sobre o projeto, consulte o [DEV_DOC.md](DEV_DOC.md) ou entre em contato com o administrador do sistema.

---

**Última atualização**: Dezembro 2025  
**Versão**: 1.0
