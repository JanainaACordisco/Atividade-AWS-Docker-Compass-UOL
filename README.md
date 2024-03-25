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

## Instruções de execução

### Configuração da Network:
- Acessei o console AWS e entrei no serviço VPC.
- No menu lateral esquerdo, na seção de *Virtual private cloud*, selecionei "Your VPCs".
- Dentro de *Your VPCs*, cliquei no botão "Create VPC".
- Alterei as seguintes configurações:
    - Em *Resources to create* selecionei "VPC and more".
    - Em *Name tag auto-generation* coloquei o nome "docker-vpc".
    - Em *Number of Availability Zones (AZs)* selecionei "2".
    - Em *NAT gateways* selecionei "In 1 AZ".
    - Em *VPC endpoints* selecionei "None".
    - Mantive as demais configurações como padrão.
- Cliquei em "Create VPC".
#### Preview
<img src=mapa-vpc.PNG>

### Configuração dos Security Groups:
- Criei os grupos de segurança usando a VPC criada anteriormente e adicionei as portas de entrada conforme a configuração abaixo:

    - Bastion Host:
        | Type | Protocol | Port Range | Source |
        |:----:|:--------:|:----------:|:------:|
        | SSH  | TCP      | 22         | My IP  |
        | HTTP | TCP      | 80         | My IP  |
    
    - Load Balancer:
        | Type | Protocol | Port Range |   Source  |
        |:----:|:--------:|:----------:|:---------:|
        | HTTP | TCP      | 80         | 0.0.0.0/0 |

    - EC2 Web Server:
        | Type | Protocol | Port Range |       Source       |
        |:----:|:--------:|:----------:|:------------------:|
        |  SSH |    TCP   |     22     | SG - Load Balancer |
        | HTTP |    TCP   |     80     |  SG - Bastion Host |   

    - RDS:
        |     Type     | Protocol | Port Range |        Source       |
        |:------------:|:--------:|:----------:|:-------------------:|
        | MYSQL/Aurora |    TCP   |    3306    |  SG - Load Balancer |
        | MYSQL/Aurora |    TCP   |    3306    | SG - EC2 Web Server |

    - EFS:
        | Type | Protocol | Port Range |        Source       |
        |:----:|:--------:|:----------:|:-------------------:|
        | NFS  | TCP      | 2049       | SG - Bastion Host   |
        | NFS  | TCP      | 2049       | SG - EC2 Web Server |

### Criando o Elastic File System:
- Acessei o console AWS e entrei no serviço de EFS.
- No menu lateral direito, cliquei no botão "Create File System".
- Depois cliquei no botão "Customize".
- Executei a seguinte configuração: 

    - #### Step 1 - File system settings
        - Coloquei o nome "EFS Docker" para o EFS.
        - Verifiquei na configuração de *File system type* se o tipo selecionado está "Regional".
        - Mantive as demais configurações como padrão.
        - Cliquei em "Next".

        - #### Step 2 - Network access:
        - No campo *Virtual Private Cloud (VPC)* selecionei a VPC que foi criada anteriormente.
        - No campo *Subnet ID* selecionei as subnets privadas de cada AZ.
        - No campo *Security groups* selecionei o grupo de segurança que foi criado para o EFS anteriormente.
        - Cliquei em "Next".

    - #### Step 3 - optional - File system policy:
        - Deixei tudo como padrão.
        - Cliquei em "Next".
        
    - #### Step 4 - Review and create:
        - Revisei e cliquei em "Create" para finalizar.

### Criando o RDS:
- Acessei o console AWS e entrei no serviço de RDS.
- No tela de *Dashboard* cliquei no botão "Create database".
- Executei a seguinte configuração:
    - Na seção *Engine options* selecionei "MySQL".
    - Na seção *Templates* selecionei "Free tier".
    - Na seção *Credentials Settings* adicionei uma *Master password* e confirmei.
    - Na seção *Conectivity*, no campo *Virtual private cloud* selecionei a VPC criada anteriormente e no campo *Existing VCP security groups* selecionei o SG que foi criado previamente para o serviço de RDS.
    - Na seção *Additional configuration*, no campo *Initial database name* coloquei o nome "dockerdb".
- Revisei e cliquei em "Create database" para finalizar.
