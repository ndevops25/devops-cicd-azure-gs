#!/bin/bash

# Criar diretórios para persistência
sudo mkdir -p /opt/jenkins/data
sudo chmod 777 /opt/jenkins/data

# Criar arquivo Docker Compose
cat > /opt/jenkins/docker-compose.yml << 'EOL'
version: '3'
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: unless-stopped
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - /opt/jenkins/data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=true
EOL

# Iniciar Jenkins com Docker Compose
cd /opt/jenkins
docker-compose up -d

# Esperar o Jenkins iniciar
echo "Aguardando Jenkins iniciar..."
while [ ! -f /opt/jenkins/data/secrets/initialAdminPassword ]; do
  sleep 5
done

# Obter e exibir a senha inicial
JENKINS_PASSWORD=$(cat /opt/jenkins/data/secrets/initialAdminPassword)
echo "Jenkins instalado com sucesso!"
echo "Senha inicial de administrador: $JENKINS_PASSWORD"
echo "Acesse o Jenkins em: http://$(hostname -I | awk '{print $1}'):8080"
echo "A senha foi salva em: /home/ubuntu/jenkins-password.txt"
echo "$JENKINS_PASSWORD" > /home/ubuntu/jenkins-password.txt