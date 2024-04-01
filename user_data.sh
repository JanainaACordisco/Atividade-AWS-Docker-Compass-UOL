#!/bin/bash
#Atualizar os pacotes do sistema
sudo yum update -y

#Instalar, iniciar e configurar a inicialização automática do docker
sudo yum install docker -y 
sudo systemctl start docker
sudo systemctl enable docker

#Adicionar o usuário ec2-user ao grupo docker
sudo usermod -aG docker ec2-user

#Instalação do docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Instalar, iniciar e configurar a inicialização automática do nfs-utils
sudo yum install nfs-utils -y
sudo systemctl start nfs-utils
sudo systemctl enable nfs-utils

#Criar a pasta onde o EFS vai ser montado
sudo mkdir /efs

#Montagem e configuração da montagem persistente do EFS
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ID-EFS:/ efs
sudo echo "ID-EFS:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

# Criar uma pasta para os arquivos do WordPress
sudo mkdir /efs/wordpress

# Criar um arquivo docker-compose.yaml para configurar o WordPress
sudo cat <<EOL > /efs/docker-compose.yaml
version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: RDS-Endpoint
      WORDPRESS_DB_USER: RDS-Master username
      WORDPRESS_DB_PASSWORD: RDS-Master password
      WORDPRESS_DB_NAME: RDS-Initial database name
      WORDPRESS_TABLE_CONFIG: wp_
    volumes:
      - /efs/wordpress:/var/www/html
EOL

# Inicializar o WordPress com docker-compose
docker-compose -f /efs/docker-compose.yaml up -d