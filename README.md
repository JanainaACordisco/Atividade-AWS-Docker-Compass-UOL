## Atividade AWS - Docker  do PB AWS e DevSecOps Compass UOL
Este repositório tem como objetivo documentar as etapas que realizei para a  execução da atividade de AWS - Docker do programa de bolsas da Compass UOL.

### Requisitos da atividade:
    - Instalação e configuração do DOCKER ou CONTAINERD no host EC2;
    - Ponto adicional para o trabalho utilizar a instalação via script de Start Instance (user_data.sh).
    - Efetuar Deploy de uma aplicação Wordpress com container de aplicação RDS database Mysql.
    - Configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress.
    - Configuração do serviço de Load Balancer AWS para a aplicação Wordpress.

### Pontos de atenção:
    - Não utilizar ip público para saída do serviços WP (Evitem publicar o serviço WP via IP Público).
    - Sugestão para o tráfego de internet sair pelo LB (Load Balancer Classic).
    - Pastas públicas e estáticos do Wordpress sugestão de utilizar o EFS (Elastic File Sistem).
    - Fica a critério de cada integrante usar Dockerfile ou Dockercompose.
    - Necessário demonstrar a aplicação Wordpress funcionando (tela de login).
    - Aplicação Wordpress precisa estar rodando na porta 80 ou 8080.
    - Utilizar repositório git para versionamento.
    - Criar documentação.

## Etapas de execução

### Configuração da Network:
- Acessei o console AWS e entrei no serviço VPC.
- No menu lateral esquerdo, na seção de Virtual private cloud, selecionei *Your VPCs*.
- Dentro de Your VPCs, cliquei no botão *Create VPC*.
- Alterei as seguintes configurações:
    - Em Resources to create selecionei *VPC and more*.
    - Em Name tag auto-generation coloquei o nome "docker-vpc".
    - Em Number of Availability Zones (AZs) selecionei *2*.
    - Em NAT gateways selecionei *In 1 AZ*.
    - Em VPC endpoints selecionei *None*.
    - Mantive as demais configurações como padrão.
- Cliquei em *Create VPC*.
#### Preview
<img src=mapa-vpc.PNG>

### Configuração dos Security Groups:
- Criei os grupos de segurança usando a VPC criada anteriormente e adicionei as portas de entrada (Inbound rules) conforme a configuração abaixo:

    - Bastion Host:
        | Type | Protocol | Port Range | Source |
        |:----:|:--------:|:----------:|:------:|
        | SSH  | TCP      | 22         | My IP  |
    
    - Load Balancer:
        | Type | Protocol | Port Range |   Source  |
        |:----:|:--------:|:----------:|:---------:|
        | HTTP | TCP      | 80         | 0.0.0.0/0 |

    - EC2 Web Server:
        | Type | Protocol | Port Range |       Source       |
        |:----:|:--------:|:----------:|:------------------:|
        |  SSH |    TCP   |     22     |  SG - Bastion Host |
        | HTTP |    TCP   |     80     | SG - Load Balancer |

    - RDS:
        |     Type     | Protocol | Port Range |        Source       |
        |:------------:|:--------:|:----------:|:-------------------:|
        | MYSQL/Aurora |    TCP   |    3306    | SG - Bastion Host   |
        | MYSQL/Aurora |    TCP   |    3306    | SG - EC2 Web Server |

    - EFS:
        | Type | Protocol | Port Range |        Source       |
        |:----:|:--------:|:----------:|:-------------------:|
        | NFS  | TCP      | 2049       | SG - Bastion Host   |
        | NFS  | TCP      | 2049       | SG - EC2 Web Server |

### Criando o Elastic File System:
- Acessei o console AWS e entrei no serviço de EFS.
- No menu lateral direito, cliquei no botão *Create File System*.
- Depois cliquei no botão *Customize*.
- Executei a seguinte configuração: 

    - #### Step 1 - File system settings
        - Coloquei o nome "efs-docker" para o EFS.
        - Mantive as demais configurações como padrão.
        - Cliquei em *Next*.

        - #### Step 2 - Network access:
        - No campo Virtual Private Cloud (VPC) selecionei a VPC que foi criada anteriormente.
        - No campo Subnet ID selecionei as subnets privadas de cada AZ.
        - No campo Security groups selecionei o grupo de segurança que foi criado para o EFS anteriormente.
        - Cliquei em *Next*.

    - #### Step 3 - optional - File system policy:
        - Deixei tudo como padrão.
        - Cliquei em *Next*.
        
    - #### Step 4 - Review and create:
        - Revisei e cliquei em *Create* para finalizar.

### Criando o RDS:
- Acessei o console AWS e entrei no serviço de RDS.
- No tela de Dashboard cliquei no botão *Create database*.
- Executei a seguinte configuração:
    - Na seção Engine options selecionei *MySQL*.
    - Na seção Templates selecionei *Free tier*.
    - Na seção Credentials Settings adicionei uma Master password e confirmei.
    - Na seção Conectivity, no campo Virtual private cloud selecionei a VPC criada anteriormente
    - No campo Existing VPC security groups selecionei o SG que foi criado previamente para o serviço de RDS.
    - Na seção Additional configuration, no campo Initial database name coloquei o nome "dockerdb".
- Revisei e cliquei em *Create database* para finalizar.

### Gerando as Key pairs:
- Acessei o console AWS e entrei no serviço EC2.
- No menu lateral esquerdo, na seção de Network & Security, selecionei *Key pairs*.
- Dentro de Key pairs, cliquei no botão *Create key pair*.
- Coloquei o nome "MinhaChaveSSH", selecionei o tipo de par de chaves como *RSA* e o formato da chave privada como *.pem* e então cliquei no botão *Create key pair*.
- Salvei o arquivo .pem.

### Criando o Launch Template :
- Acessei o console AWS e na seção Instances cliquei no botão *Launch Templates*.
- Na tela de Launch Templates cliquei no botão *Create launch template*.
- No campo Launch template name coloquei o nome de "ws-lt".
- No campo Template version description escrevi "docker-wordpress"
- Em Application and OS Images cliquei em *Quick Start*, depois cliquei em *Amazon Linux* e selecionei a *Amazon Linux 2023 AMI*.
- Na seção Instance type selecionei o tipo *t3.small*.
- No campo Key pair name selecionei a key pair criada anteriormente.
- Em Network settings, no campo Security groups selecionei o grupo *EC2 Web Server* que foi criado anteriormente.
- Em Resource tags, cliquei em *Add new tag* e adicionei as tags de Key: *Name, Project e CostCenter* (com seus respectivos *Value*) para os Resource types *Instances e Volumes*.
- Em Advanced details, no campo User data adicionei o script abaixo:
    ```
    #!/bin/bash
    #Atualizar os pacotes do sistema
    sudo yum update -y

    #Instalar, iniciar e configurar a inicialização automática do docker
    sudo yum install docker -y 
    sudo systemctl start docker.service
    sudo systemctl enable docker.service
    
    #Adicionar o usuário ec2-user ao grupo docker
    sudo usermod -aG docker ec2-user

    #Instalação do docker-compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose

    #Instalar, iniciar e configurar a inicialização automática do nfs-utils
    sudo yum install nfs-utils -y
    sudo systemctl start nfs-utils.service
    sudo systemctl enable nfs-utils.service

    #Criar a pasta onde o EFS vai ser montado
    sudo mkdir -p /efs

    #Montagem e configuração da montagem automática do EFS
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ID-EFS:/ efs
    sudo echo "ID-EFS:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

    # Cria uma pasta para os arquivos do WordPress
    sudo mkdir -p /efs/wordpress

    # Cria um arquivo docker-compose.yml para configurar o WordPress
    sudo cat <<EOL > /efs/docker-compose.yaml
    version: '3.8'
    services:
    wordpress:
        image: wordpress:latest
        container_name: wordpress
        ports:
          - "80:80"
        environment:
          WORDPRESS_DB_HOST: RDS-ENDPOINT
          WORDPRESS_DB_USER: RDS Master user
          WORDPRESS_DB_PASSWORD: RDS Master user password
          WORDPRESS_DB_NAME: RDS Initial name
          WORDPRESS_TABLE_CONFIG: wp_
        volumes:
          - /efs/wordpress:/var/www/html
    EOL

    # Inicializar o WordPress com Docker Compose
    sudo docker-compose -f /efs/docker-compose.yaml up -d
    ```
- Cliquei em *Create launch template* para finalizar.