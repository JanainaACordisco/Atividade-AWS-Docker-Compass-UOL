## Atividade AWS - Docker  do PB AWS e DevSecOps Compass UOL
Este repositório tem como objetivo documentar as etapas da atividade de AWS - Docker do programa de bolsas da Compass UOL.

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
- Acesse o console AWS e entre no serviço VPC.
- No menu lateral esquerdo, na seção de "Virtual private cloud", selecione "Your VPCs".
- Dentro de Your VPCs, clique no botão "Create VPC".
- Altere as seguintes configurações:
    - Em Resources to create selecione "VPC and more".
    - Em Name tag auto-generation coloque o nome de sua escolha.
    - Em Number of Availability Zones (AZs) selecione "2".
    - Em NAT gateways selecione "In 1 AZ".
    - Em VPC endpoints selecione "None".
    - Manter as demais configurações como padrão.
- Clique em "Create VPC".
### Preview
<img src=mapa-vpc.PNG>