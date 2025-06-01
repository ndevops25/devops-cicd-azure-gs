Pipeline CI/CD com Jenkins, SonarQube, ACR e ACI 🚀
===================================================

Este projeto implementa um pipeline completo de CI/CD usando Jenkins para uma aplicação Python Flask, com deploy automatizado na Azure utilizando Docker, ACR (Azure Container Registry) e ACI (Azure Container Instance), Trivy para escaneamento de vulnerabilidades, proxy de segurança com OWASP-ZAP e alertas e monitoramento com Prometheus e Grafana. Inclui análise de código com SonarQube para manter a qualidade do código.

<img src="/docs/images/architecture/layered-architecture.png" alt="Azure Layered Architecture">

📋 Índice
---------

-   [Arquitetura](#arquitetura)
-   [Pré-requisitos](#pr%C3%A9-requisitos)
-   [Estrutura do Projeto](#estrutura-do-projeto)
-   [Configuração da Infraestrutura](#configura%C3%A7%C3%A3o-da-infraestrutura)
-   [Configuração do Jenkins](#configura%C3%A7%C3%A3o-do-jenkins)
-   [Configuração do SonarQube](#configura%C3%A7%C3%A3o-do-sonarqube)
-   [Pipeline CI/CD](#pipeline-cicd)
-   [Deploy da Aplicação](#deploy-da-aplica%C3%A7%C3%A3o)
-   [Monitoramento](#monitoramento)
-   [Troubleshooting](#troubleshooting)
-   [Resultados da Análise de Código](#resultados-da-an%C3%A1lise-de-c%C3%B3digo)
-   [Segurança](#seguran%C3%A7a)
-   [Contribuindo](#contribuindo)
-   [Licença](#licen%C3%A7a)
-   [Autores](#autores)

## Para seguir os passos de configurações do Jenkins e SonarQube, veja as imagens na pasta docs/images

🏗️ Arquitetura
---------------

### Componentes:

-   **GitHub**: Repositório de código fonte
-   **Jenkins**: Servidor de CI/CD para execução do pipeline
-   **SonarQube**: Ferramenta de análise de qualidade de código
-   **Trivy**: Scanner de vulnerabilidades
-   **OWASP ZAP** - Testes de segurança web
-   **Prometheus** - Métrica
-   **Grafana** - Dashboards
-   **Docker**: Containerização da aplicação
-   **ECR**: Registro de imagens Docker na AWS
-   **ECS/Fargate**: Orquestração de containers sem servidor
-   **ALB**: Load Balancer para distribuição de tráfego

-   Jenkins: <http://52.179.0.47:8080/>
    - Login: admin
    - Senha: admin

-   SonarQube: <http://52.179.3.47:9000/>
    - Login: thunderbolts
    - Senha: Fiap123

**🚀 Parte em desenvolvimento - DevSecOps completo:**
--------------------------------------------

### **🛡️ Segurança (DevSecOps):**

-   **Trivy** - Scanner de vulnerabilidades
-   **OWASP ZAP** - Testes de segurança web

### **📊 Observabilidade:**

-   **Prometheus** - Métricas
-   **Grafana** - Dashboards

🔧 Pré-requisitos
-----------------

### Ferramentas Necessárias:

-   Azure CLI configurado
-   Terraform >= 1.0
-   Git
-   Docker
-   Conta Azure com permissões adequadas
-   JDK 11 ou superior (para Jenkins)
-   Python 3.9+ (para aplicação de exemplo)

### Conhecimentos Requeridos:

-   Conceitos básicos de CI/CD
-   Docker e containerização
-   Azure Services (VM, ACR, ACI, VNET)
-   Terraform para IaC
-   Análise de qualidade de código com SonarQube

🚀 Estrutura do Projeto DEVSECOPS-Azure
==================================

```
DEVSECOPS-AWS/
├── docs/                                    # Documentação do projeto
│   ├── architecture/                        # Documentação da arquitetura
│   └── images/                             # Imagens e diagramas
├── pipelines/aws/                          # Pipelines de CI/CD para AWS
│   └── Jenkinsfile                         # Pipeline Jenkins principal
├── sample-app/                             # Aplicação de exemplo
│   ├── .gitignore                          # Arquivos ignorados pelo Git
│   ├── app.py                              # Aplicação Flask Python
│   ├── Dockerfile                          # Imagem Docker da aplicação
│   ├── Jenkinsfile                         # Pipeline Jenkins da aplicação
│   ├── requirements.txt                    # Dependências Python
│   ├── sonar-project.properties            # Configuração do SonarQube
│   └── test_app.py                         # Testes unitários da aplicação
├── scripts/                                # Scripts auxiliares
├── terraform/aws/                          # Infraestrutura como Código
│   ├── modules/                            # Módulos Terraform reutilizáveis
│   │   ├── compute/                        # Módulo para instâncias EC2
│   │   │   ├── ami.tf                      # Configuração de AMIs
│   │   │   ├── iam.tf                      # Roles e políticas IAM
│   │   │   ├── jenkins_compute.tf          # Instâncias para Jenkins
│   │   │   ├── jenkins.sh                  # Script de inicialização Jenkins
│   │   │   ├── locals.tf                   # Variáveis locais
│   │   │   ├── outputs.tf                  # Outputs do módulo
│   │   │   ├── sonarqube_compute.tf        # Instâncias para SonarQube
│   │   │   ├── sonarqube.sh                # Script de inicialização SonarQube
│   │   │   └── variables.tf                # Variáveis do módulo
│   │   ├── devsecops/                      # Módulo DevSecOps
│   │   │   ├── monitoring/prometheus-grafana/  # Stack de monitoramento
│   │   │   │   ├── temp_build/             # Arquivos temporários de build
│   │   │   │   ├── build_monitoring_stack.tf   # Build da stack de monitoramento
│   │   │   │   ├── grafana_config.tf       # Configuração do Grafana
│   │   │   │   ├── grafana_dashboards.tf   # Dashboards do Grafana
│   │   │   │   ├── grafana_datasources.tf  # Fontes de dados do Grafana
│   │   │   │   ├── grafana_dockerfile.tf   # Dockerfile do Grafana
│   │   │   │   ├── monitoring_stack_aci.tf # Stack de monitoramento no ACI
│   │   │   │   ├── monitoring_stack_dockerfile.tf # Dockerfile da stack
│   │   │   │   ├── outputs.tf              # Outputs do monitoramento
│   │   │   │   ├── prometheus_alerts.tf    # Alertas do Prometheus
│   │   │   │   ├── prometheus_config.tf    # Configuração do Prometheus
│   │   │   │   └── variables.tf            # Variáveis do monitoramento
│   │   │   ├── pipeline/jenkins/           # Pipeline Jenkins
│   │   │   │   ├── main.tf                 # Configuração principal Jenkins
│   │   │   │   ├── outputs.tf              # Outputs do pipeline
│   │   │   │   └── variables.tf            # Variáveis do pipeline
│   │   │   ├── proxy-security/owasp-zap/   # Proxy de segurança OWASP ZAP
│   │   │   │   ├── temp_build/             # Arquivos temporários
│   │   │   │   ├── build_zap_image.tf      # Build da imagem ZAP
│   │   │   │   ├── outputs.tf              # Outputs do ZAP
│   │   │   │   ├── owasp_zap_aci.tf        # ZAP no Azure Container Instances
│   │   │   │   ├── variables.tf            # Variáveis do ZAP
│   │   │   │   ├── zap_dashboard_app.tf    # Dashboard do ZAP
│   │   │   │   ├── zap_dashboard_template.tf # Template do dashboard ZAP
│   │   │   │   ├── zap_dockerfile.tf       # Dockerfile do ZAP
│   │   │   │   └── zap_report_template.tf  # Template de relatório ZAP
│   │   │   ├── quality-assurance/sonarqube/ # Garantia de qualidade
│   │   │   │   ├── main.tf                 # Configuração principal SonarQube
│   │   │   │   ├── outputs.tf              # Outputs do SonarQube
│   │   │   │   └── variables.tf            # Variáveis do SonarQube
│   │   │   └── security-scanner/trivy/     # Scanner de segurança Trivy
│   │   │       ├── temp_build/             # Arquivos temporários
│   │   │       ├── build_trivy_image.tf    # Build da imagem Trivy
│   │   │       ├── outputs.tf              # Outputs do Trivy
│   │   │       ├── trivy_dashboard_aci.tf  # Dashboard Trivy no ACI
│   │   │       ├── trivy_dashboard_app.tf  # Aplicação dashboard Trivy
│   │   │       ├── trivy_dashboard_template.tf # Template dashboard Trivy
│   │   │       ├── trivy_dockerfile.tf     # Dockerfile do Trivy
│   │   │       ├── trivy_report_template.tf # Template relatório Trivy
│   │   │       └── variables.tf            # Variáveis do Trivy
│   │   ├── ecr/                            # Elastic Container Registry
│   │   │   ├── main.tf                     # Configuração principal ECR
│   │   │   ├── outputs.tf                  # Outputs do ECR
│   │   │   └── variables.tf                # Variáveis do ECR
│   │   ├── ecs/                            # Elastic Container Service
│   │   │   ├── main.tf                     # Configuração principal ECS
│   │   │   ├── outputs.tf                  # Outputs do ECS
│   │   │   └── variables.tf                # Variáveis do ECS
│   │   ├── elastic-ip/                     # IPs Elásticos
│   │   │   ├── main.tf                     # Configuração de IPs elásticos
│   │   │   ├── outputs.tf                  # Outputs dos IPs
│   │   │   └── variables.tf                # Variáveis dos IPs
│   │   ├── network/                        # Configuração de rede
│   │   │   ├── main.tf                     # Configuração principal da rede
│   │   │   ├── outputs.tf                  # Outputs da rede
│   │   │   └── variables.tf                # Variáveis da rede
│   │   └── security/                       # Configuração de segurança
│   │       ├── main.tf                     # Configuração principal segurança
│   │       ├── outputs.tf                  # Outputs de segurança
│   │       ├── providers.tf                # Provedores Terraform
│   │       └── variables.tf                # Variáveis de segurança
│   ├── main.tf                             # Arquivo principal Terraform
│   ├── outputs.tf                          # Outputs principais
│   └── variables.tf                        # Variáveis principais
├── .gitignore                              # Arquivos ignorados pelo Git
└── README.md                               # Documentação principal do projeto

```

Descrição dos Componentes Principais
------------------------------------

### 🏗️ **Terraform/Azure**

-   **Infraestrutura como Código** para provisionamento de recursos Azure
-   **Módulos reutilizáveis** para diferentes componentes da arquitetura
-   **Configuração modular** para facilitar manutenção e escalabilidade

### 🔧 **Sample-App**

-   **Aplicação Flask** de exemplo para demonstrar o pipeline
-   **Testes unitários** e configuração de qualidade de código
-   **Containerização** com Docker

### 🚀 **DevSecOps Pipeline**

-   **Jenkins** para CI/CD
-   **SonarQube** para análise de qualidade de código
-   **OWASP ZAP** para testes de segurança
-   **Trivy** para scanner de vulnerabilidades
-   **Prometheus/Grafana** para monitoramento

### 🔐 **Segurança Integrada**

-   **Análise estática** de código
-   **Testes de penetração** automatizados
-   **Scanner de vulnerabilidades** em containers
-   **Monitoramento** de segurança em tempo real

### ☁️ **Serviços Azure**

-   **Azure VMs** para instâncias de compute
-   **ACR** para registry de containers
-   **ACI** para orquestração de containers
-   **VNET** para isolamento de rede
-   **NSGs** para controle de acesso


🚀 Configuração da Infraestrutura
---------------------------------

### 1\. Preparar Backend do Terraform

bash

```
cd terraform/
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

- Depois do Build, esta será a saída do output:
<img src="/docs/images/steps/terraform/outputs1.png" alt="Terraform Output 1">
<img src="/docs/images/steps/terraform/outputs2.png" alt="Terraform Output 2">

### 4\. Recursos Criados

-   VPC com subnets públicas e privadas
-   Security Groups configurados
-   Instância VM com Jenkins
-   Instância VM com SonarQube
-   ACR Repository
-   ACI Cluster
-   Application Load Balancer

⚙️ Configuração do Jenkins
--------------------------

<img src="/docs/images/steps/jenkins/pipeline-jenkins-sonarqube.png" alt="Jenkins Pipeline inegrated with SonarQube">

### 1\. Acessar Jenkins

bash

```
# Obter URL do Jenkins
JENKINS_URL=$(terraform output -raw jenkins_url)
echo $JENKINS_URL

# Obter senha inicial
ssh -i ~/.ssh/jenkins-key-dev.pem ubuntu@<IP>\
    "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

### 2\. Configuração Inicial

1.  Acessar URL do Jenkins no navegador (<http://52.179.0.47:8080>)
2.  Inserir senha inicial
3.  Instalar plugins sugeridos
4.  Criar usuário administrador

### 3\. Plugins Necessários

-   Docker Pipeline
-   Azure ACR
-   Pipeline: AWS Steps
-   GitHub Integration
-   SonarQube Scanner
-   Blue Ocean (opcional)

### 4\. Configurar Credenciais

#### GitHub Token:

1.  GitHub → Settings → Developer settings → Personal access tokens
2.  Gerar novo token com permissões: `repo`, `workflow`
3.  No Jenkins: Manage Jenkins → Credentials → Add Credentials
    -   Kind: Username with password
    -   ID: `github-credentials`
    -   Username: seu-usuario-github
    -   Password: token-gerado

#### AWS Credentials:

1.  No Jenkins: Manage Jenkins → Credentials → Add Credentials
    -   Kind: Secret text
    -   ID: `azure-client-id`
    -   Secret: sua-access-key
2.  No Jenkins: Manage Jenkins → Credentials → Add Credentials
    -   Kind: Secret text
    -   ID: `azure-client-secret`
    -   Secret: sua-secret-key
3. No Jenkins: Manage Jenkins → Credentials → Add Credentials
    -   Kind: Secret text
    -   ID: `azure-tenant-id`
    -   Secret: sua-secret-key
4. No Jenkins: Manage Jenkins → Credentials → Add Credentials
    -   Kind: Secret text
    -   ID: `azure-subscription-id`
    -   Secret: sua-secret-key

#### SonarQube Token:

1.  No SonarQube: Administration → Security → Users → Tokens
2.  Gerar novo token com nome "jenkins-integration"
3.  No Jenkins: Manage Jenkins → Credentials → Add Credentials
    -   Kind: Secret text
    -   ID: `sonarqube-token`
    -   Secret: token-gerado-no-sonarqube

<img src="/docs/images/steps/sonarqube/quality-config/token-config-path.png" alt="Configuração do Token no SonarQube">

📊 Configuração do SonarQube
----------------------------

### 1\. Acesso ao SonarQube

O SonarQube está disponível em <http://52.179.3.47:9000> com as seguintes credenciais padrão:

-   Username: admin
-   Password: admin (alterada na primeira configuração)

### 2\. Configuração do SonarQube Scanner

1.  Manage Jenkins → Tools → SonarQube Scanner installations
2.  Adicionar SonarQube Scanner:
    -   Nome: SonarScanner
    -   Versão: SonarQube Scanner 4.7.0.2747
    -   Selecionar "Instalar automaticamente"

- Para baixar a extensão, vá para "Extensões Disponíveis":
<img src="/docs/images/steps/jenkins/sonarqube/install-scanner-plugin.png" alt="Configuração do SonarQube Scanner Plugin">

- Configuração do SonarQube Scanner com o plugin instalado na plataforma Jenkins:
<img src="/docs/images/steps/jenkins/sonarqube/sonarqube-scanner-config.png" alt="Configuração do SonarQube Scanner Config">


### 3\. Configuração no Jenkins

1.  Instalar o plugin "SonarQube Scanner" no Jenkins
2.  Configurar o SonarQube no Jenkins:
    -   Manage Jenkins → System → SonarQube servers
    -   Nome: SonarQube
    -   URL do servidor: <http://52.179.3.47:9000>
    -   Token de autenticação: Selecionar credencial `sonarqube-token`

<img src="/docs/images/steps/jenkins/sonarqube/sonarqube-scanner-config.png" alt="Configuração do SonarQube Scanner">

### 4\. Configuração do Projeto no SonarQube

1.  Criar projeto no SonarQube com a chave "sample-app"
2.  Configurar arquivo `sonar-project.properties`:

properties

```
# Identificação do projeto
sonar.projectKey=sample-app
sonar.projectName=Sample App
sonar.projectVersion=1.0

# Configurações do servidor
sonar.host.url=http://52.179.3.47:9000

# Caminho para os arquivos de código
sonar.sources=.
sonar.python.coverage.reportPaths=coverage.xml
sonar.python.xunit.reportPath=test-results.xml

# Codificação do código-fonte
sonar.sourceEncoding=UTF-8
```

📦 Pipeline CI/CD
-----------------

O pipeline CI/CD é definido no Jenkinsfile e consiste nas seguintes etapas:

### 1\. Verificação de Acesso Azure

Verifica se o Jenkins tem acesso correto à Azure usando as credenciais configuradas.

### 2\. Análise de Código com SonarQube

Executa análise estática de código com SonarQube para identificar problemas de qualidade, vulnerabilidades e bugs.

### 3\. Build e Teste da Aplicação

Constrói a imagem Docker da aplicação e executa testes para verificar seu funcionamento.

### 4\. Push para ACR

Envia a imagem Docker para o Azure ACR para armazenamento seguro.

### 5\. Deploy no ACI

Atualiza o serviço ACI com a nova imagem, implementando a aplicação em produção.

### Execução do Pipeline

Para executar o pipeline, você pode:

1.  Acessar o Jenkins e selecionar o projeto "service-app"
2.  Clicar em "Build Now"
3.  Acompanhar a execução nos logs ou na visualização de estágios

- Pipeline executado:
<img src="/docs/images/steps/jenkins/pipeline-jenkins-sonarqube.png" alt="Jenkins Pipeline Executed with SonarQube">

🔍 Resultados da Análise de Código
----------------------------------

Após a execução do pipeline, é possível visualizar os resultados da análise de código no SonarQube:

- Dashboard de Qualidade de Software na plataforma do SonarQube:
<img src="/docs/images/steps/sonarqube/sonarqube-project.png" alt="SonarQube Dashboard">

- Pressione a linha de informações para ver os detalhes da inspeção de qualidade:
<img src="/docs/images/steps/sonarqube/quality-code-details.png" alt="SonarQube Details Dashboard">

Os resultados atuais mostram:

-   0 Bugs detectados
-   0 Vulnerabilidades de segurança
-   2 Security Hotspots para revisão (0.0% revisados)
-   0 Code Smells
-   0% de Cobertura de código em 40 linhas
-   0% de Duplicação de código em 209 linhas

Todos os Quality Gates foram aprovados, resultando em status "Passed".


🔍 Troubleshooting
------------------

### Problemas com o SonarQube

Se o SonarScanner não estiver funcionando:

1.  Verificar se o plugin do SonarQube está instalado no Jenkins
2.  Confirmar se as credenciais do token SonarQube estão corretas
3.  Verificar conectividade entre Jenkins e SonarQube
4.  Examinar os logs do SonarQube:

    bash

    ```
    docker logs sonarqube-container
    ```

### Pipeline falhando

1.  Verificar acesso às credenciais da Azure
3.  Verificar conectividade de rede entre Jenkins, SonarQube e Azure
4.  Examinar os logs do pipeline para identificar o ponto de falha


🔐 Segurança
------------

### Boas Práticas Implementadas:

-   Secrets gerenciados como credenciais no Jenkins
-   IAM roles com princípio do menor privilégio
-   Security Groups restritivos
-   Análise de segurança com SonarQube
-   Escaneamento de vulnerabilidades em imagens Docker

### Melhorias Recomendadas:

-   Implementar VPN para acesso ao Jenkins
-   Usar AWS Secrets Manager para senhas
-   Habilitar MFA para usuários Jenkins

🤝 Contribuindo
---------------

1.  Fork o projeto
2.  Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3.  Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4.  Push para a branch (`git push origin feature/AmazingFeature`)
5.  Abra um Pull Request

📝 Licença
----------

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

👥 Autores
----------

-   **ndevops25** - *Trabalho Inicial* - [ndevops25](https://github.com/ndevops25)

🙏 Agradecimentos
-----------------

-   Professor pela orientação
-   Colegas de turma pelo apoio
-   Documentação da Azure, Jenkins e SonarQube

* * * * *

**Nota**: Este projeto foi desenvolvido como parte do trabalho CP2 e CP3 - Construção de um Pipeline CI/CD usando Jenkins e SonarQube.
