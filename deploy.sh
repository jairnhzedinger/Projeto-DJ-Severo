#!/bin/bash

# Atualizar pacotes e instalar dependências necessárias
sudo apt update
sudo apt upgrade -y
sudo apt install -y git curl php php-cli php-mbstring php-xml php-zip composer docker.io

# Clonar o repositório
REPO_URL="https://github.com/cai0arruda/Projeto-DJ-Severo.git"
git clone $REPO_URL project
cd project

# Perguntar ao usuário as variáveis de ambiente para o .env
echo "Configurando o arquivo .env..."

echo "Informe o host do banco de dados (DB_HOST):"
read DB_HOST
echo "Informe o usuário do banco de dados (DB_USER):"
read DB_USER
echo "Informe o nome do banco de dados (DB_USERNAME):"
read DB_USERNAME
echo "Informe a senha do banco de dados (DB_PASSWORD):"
read -s DB_PASSWORD

# Criar arquivo .env
cat <<EOL > .env
DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
EOL

# Instalar dependências do Composer
composer install

# Gerar chave da aplicação (se necessário)
if [ -f "artisan" ]; then
    php artisan key:generate
fi

# Build da imagem Docker
echo "Construindo a imagem Docker..."
docker build -t projeto-dj-severo .

# Iniciar o contêiner Docker
echo "Iniciando o contêiner Docker..."
docker run -d -p 80:80 --env-file .env projeto-dj-severo

echo "Instalação completa! Acesse a aplicação em http://localhost"
