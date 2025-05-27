#!/bin/bash

# Criar diretórios para persistência
sudo mkdir -p /opt/sonarqube/data
sudo mkdir -p /opt/sonarqube/logs
sudo mkdir -p /opt/sonarqube/extensions
sudo mkdir -p /opt/sonarqube/conf
sudo mkdir -p /opt/sonarqube/postgresql
sudo chmod -R 777 /opt/sonarqube

# Configurar kernel para SonarQube
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Criar arquivo Docker Compose
cat > /opt/sonarqube/docker-compose.yml << 'EOL'
version: '3'
services:
  sonarqube-db:
    image: postgres:13
    container_name: sonarqube-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonar
    volumes:
      - /opt/sonarqube/postgresql:/var/lib/postgresql/data

  sonarqube:
    image: sonarqube:9.9-community
    container_name: sonarqube
    restart: unless-stopped
    depends_on:
      - sonarqube-db
    ports:
      - "9000:9000"
    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://sonarqube-db:5432/sonar
      - SONARQUBE_JDBC_USERNAME=sonar
      - SONARQUBE_JDBC_PASSWORD=sonar
    volumes:
      - /opt/sonarqube/data:/opt/sonarqube/data
      - /opt/sonarqube/logs:/opt/sonarqube/logs
      - /opt/sonarqube/extensions:/opt/sonarqube/extensions
      - /opt/sonarqube/conf:/opt/sonarqube/conf
EOL

# Iniciar SonarQube com Docker Compose
cd /opt/sonarqube
docker-compose up -d

echo "SonarQube instalado com sucesso!"
echo "Acesse o SonarQube em: http://$(hostname -I | awk '{print $1}'):9000"
echo "Credenciais padrão: admin/admin"