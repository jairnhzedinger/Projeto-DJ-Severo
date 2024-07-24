#!/bin/bash

# Atualizar pacotes e instalar Docker
sudo apt update
sudo apt upgrade -y
sudo apt install -y git docker.io

# Verificar se o Docker está rodando e tentar iniciar se não estiver
echo "Verificando o status do Docker..."
sudo systemctl start docker
sleep 30
sudo systemctl is-active --quiet docker
if [ $? -ne 0 ]; then
  echo "Docker não está rodando. Tentando iniciar o Docker..."
  sudo systemctl start docker
  sleep 30
  sudo systemctl is-active --quiet docker
  if [ $? -ne 0 ]; then
    echo "Não foi possível iniciar o Docker. Por favor, verifique manualmente."
    exit 1
  else
    echo "Docker iniciado com sucesso."
  fi
else
  echo "Docker já está rodando."
fi

# Perguntar ao usuário as variáveis de ambiente para o .env, se ele não existir
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
  echo "Arquivo .env já existe. Pulando configuração."
else
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
fi

# Baixar e iniciar o contêiner Docker usando a imagem do Docker Hub
IMAGE_NAME="jairnhzedinger/djsevero-app:latest"
echo "Iniciando o contêiner Docker com a imagem $IMAGE_NAME..."

# Verificar se o contêiner já está em execução
CONTAINER_ID=$(docker ps -q --filter ancestor=$IMAGE_NAME)
if [ -z "$CONTAINER_ID" ]; then
  docker run -d -p 3000:80 --env-file .env $IMAGE_NAME
  if [ $? -eq 0 ]; then
    echo "Contêiner iniciado com sucesso! Acesse a aplicação em http://localhost:3000"
  else
    echo "Falha ao iniciar o contêiner. Por favor, verifique os logs do Docker."
    exit 1
  fi
else
  echo "Contêiner já está em execução."
fi
