# Inception

*Este projeto foi criado como parte do currículo 42 por edcastro*

## Descrição

O **Inception** é um projeto de infraestrutura que tem como objetivo criar um pequeno ambiente de servidor usando Docker. O projeto consiste em configurar uma infraestrutura completa usando Docker Compose, com os seguintes serviços:

- **NGINX**: Servidor web com suporte a TLSv1.2 ou TLSv1.3
- **WordPress**: Sistema de gerenciamento de conteúdo com PHP-FPM
- **MariaDB**: Sistema de gerenciamento de banco de dados

Cada serviço roda em seu próprio container Docker, construído a partir de imagens personalizadas baseadas na penúltima versão estável do Alpine ou Debian. Os containers são configurados para reiniciar automaticamente em caso de falha e se comunicam através de uma rede Docker dedicada.

### Características Principais

- Containers Docker personalizados para cada serviço
- Configuração de rede isolada entre os containers
- Volumes persistentes para dados do banco de dados e arquivos do WordPress
- Certificado SSL/TLS para conexões HTTPS
- Configuração automatizada através de scripts de inicialização
- Variáveis de ambiente para configuração sensível

## Instruções

### Pré-requisitos

- Sistema operacional Linux
- Docker e Docker Compose instalados
- Permissões de superusuário (sudo)
- Porta 443 disponível

### Instalação Rápida

1. Clone o repositório:
```bash
git clone <seu-repositorio>
cd Inception
```

2. (Opcional) Instale o Docker se ainda não tiver:
```bash
make install
```

3. Execute o projeto:
```bash
make
```

4. Acesse o site em: `https://edcastro.42.fr`

### Comandos Disponíveis

- `make` ou `make build` - Constrói e inicia todos os containers
- `make down` - Para os containers sem removê-los
- `make clean` - Remove completamente todos os containers, volumes e dados
- `make restart` - Reinicia todo o ambiente (clean + build)
- `make kill` - Para forçadamente todos os containers

Para mais detalhes de uso, consulte o arquivo [USER_DOC.md](USER_DOC.md).

Para informações técnicas e de desenvolvimento, consulte o arquivo [DEV_DOC.md](DEV_DOC.md).

## Recursos

### Uso de Inteligência Artificial

Durante o desenvolvimento deste projeto, ferramentas de IA foram utilizadas para auxiliar nas seguintes áreas:

1. **Documentação**: A IA auxiliou na criação e estruturação da documentação técnica e de usuário, garantindo clareza e organização das informações.

2. **Debugging**: Utilizada para identificar e resolver problemas de configuração do Docker e dos serviços, especialmente relacionados a:
   - Configurações de rede entre containers
   - Healthchecks e dependências entre serviços
   - Problemas de permissões em volumes

3. **Otimização de Dockerfiles**: Assistência na criação de Dockerfiles otimizados seguindo as melhores práticas:
   - Redução do tamanho das imagens
   - Ordenação adequada de camadas para melhor cache
   - Implementação de multi-stage builds quando aplicável

4. **Scripts de Inicialização**: Apoio no desenvolvimento de scripts shell para configuração automatizada dos serviços (MariaDB e WordPress).

5. **Configuração de Segurança**: Orientação sobre melhores práticas de segurança:
   - Configuração SSL/TLS do NGINX
   - Gerenciamento seguro de credenciais através de variáveis de ambiente
   - Princípio do menor privilégio nos containers

A IA foi utilizada como ferramenta de apoio e aprendizado, mas todo o código foi revisado, compreendido e adaptado às necessidades específicas do projeto e aos requisitos da 42.

## Estrutura do Projeto

```
.
├── Makefile                    # Comandos para gerenciar o projeto
├── README.md                   # Este arquivo
├── USER_DOC.md                 # Documentação para usuários finais
├── DEV_DOC.md                  # Documentação para desenvolvedores
└── srcs/
    ├── docker-compose.yml      # Orquestração dos containers
    ├── .env                    # Variáveis de ambiente (não versionado)
    └── requirements/
        ├── mariadb/            # Container do banco de dados
        ├── nginx/              # Container do servidor web
        └── wordpress/          # Container do WordPress
```

## Licença

Este projeto faz parte do currículo da 42 e está sujeito às suas políticas.

## Autor

**edcastro** - Estudante da 42
