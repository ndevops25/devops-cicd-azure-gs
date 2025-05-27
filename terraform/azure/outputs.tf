# ========================================
# OUTPUTS PRINCIPAIS - INFRAESTRUTURA
# ========================================

output "resource_group_name" {
  description = "Nome do grupo de recursos"
  value       = module.resource_group.name
}

output "location" {
  description = "Localização dos recursos"
  value       = var.location
}

# ========================================
# OUTPUTS - MÁQUINAS VIRTUAIS
# ========================================

output "jenkins_vm_public_ip" {
  description = "Endereço IP público da VM Jenkins"
  value       = module.jenkins_vm.public_ip_address
}

output "jenkins_vm_private_ip" {
  description = "Endereço IP privado da VM Jenkins"
  value       = module.jenkins_vm.private_ip_address
}

output "sonarqube_vm_public_ip" {
  description = "Endereço IP público da VM SonarQube"
  value       = module.sonarqube_vm.public_ip_address
}

output "sonarqube_vm_private_ip" {
  description = "Endereço IP privado da VM SonarQube"
  value       = module.sonarqube_vm.private_ip_address
}

# ========================================
# OUTPUTS - CONTAINER REGISTRY (ACR)
# ========================================

output "container_registry_login_server" {
  description = "URL do servidor de login do Azure Container Registry"
  value       = module.container_registry.login_server
}

output "container_registry_admin_username" {
  description = "Nome de usuário admin do Container Registry"
  value       = module.container_registry.admin_username
}

output "container_registry_admin_password" {
  description = "Senha admin do Container Registry"
  value       = module.container_registry.admin_password
  sensitive   = true
}

output "container_registry_id" {
  description = "ID do Azure Container Registry"
  value       = module.container_registry.id
}

# ========================================
# OUTPUTS - AZURE CONTAINER INSTANCES (ACI)
# ========================================

output "python_app_fqdn" {
  description = "FQDN da aplicação Python no ACI"
  value       = module.container_instances.app_fqdn
}

output "python_app_ip_address" {
  description = "IP público da aplicação Python"
  value       = module.container_instances.app_ip_address
}

output "python_app_url" {
  description = "URL completa para acessar a aplicação Python"
  value       = module.container_instances.app_url
}

output "python_app_container_group_id" {
  description = "ID do Container Group da aplicação Python"
  value       = module.container_instances.container_group_id
}

# ========================================
# OUTPUTS - APPLICATION GATEWAY
# ========================================

output "app_gateway_public_ip" {
  description = "Endereço IP público do Application Gateway"
  value       = module.app_gateway.public_ip_address
}

output "app_gateway_fqdn" {
  description = "FQDN do Application Gateway"
  value       = module.app_gateway.fqdn
}

output "app_gateway_url" {
  description = "URL do Application Gateway (entrada principal)"
  value       = "http://${module.app_gateway.fqdn}"
}

# ========================================
# OUTPUTS - REDE
# ========================================

output "virtual_network_name" {
  description = "Nome da rede virtual"
  value       = module.networking.vnet_name
}

output "virtual_network_id" {
  description = "ID da rede virtual"
  value       = module.networking.vnet_id
}

output "subnets" {
  description = "IDs das subnets criadas"
  value = {
    app_subnet       = module.networking.app_subnet_id
    container_subnet = module.networking.container_subnet_id
    gateway_subnet   = module.networking.gateway_subnet_id
  }
}

# ========================================
# OUTPUTS - SSH E ACESSO
# ========================================

output "ssh_private_key" {
  description = "Chave SSH privada para acesso às VMs"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_public_key" {
  description = "Chave SSH pública"
  value       = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_connection_commands" {
  description = "Comandos para conectar às VMs via SSH"
  value = {
    jenkins   = "ssh -i ssh-keys/id_rsa ${var.admin_username}@${module.jenkins_vm.public_ip_address}"
    sonarqube = "ssh -i ssh-keys/id_rsa ${var.admin_username}@${module.sonarqube_vm.public_ip_address}"
  }
}

# ========================================
# OUTPUTS - URLS DE ACESSO RÁPIDO
# ========================================

output "access_urls" {
  description = "URLs para acessar os serviços"
  value = {
    jenkins_vm        = "http://${module.jenkins_vm.public_ip_address}:8080"
    sonarqube_vm      = "http://${module.sonarqube_vm.public_ip_address}:9000"
    python_app_direct = module.container_instances.app_url
    python_app_gateway = "http://${module.app_gateway.fqdn}"
    container_registry = "https://${module.container_registry.login_server}"
  }
}

# ========================================
# OUTPUTS - COMANDOS ÚTEIS
# ========================================

output "useful_commands" {
  description = "Comandos úteis para gerenciar a infraestrutura"
  value = {
    # ACR Commands
    acr_login = "az acr login --name ${split(".", module.container_registry.login_server)[0]}"
    acr_list_images = "az acr repository list --name ${split(".", module.container_registry.login_server)[0]}"
    
    # ACI Commands
    aci_logs = "az container logs --resource-group ${module.resource_group.name} --name ${module.container_instances.container_group_name}"
    aci_restart = "az container restart --resource-group ${module.resource_group.name} --name ${module.container_instances.container_group_name}"
    aci_status = "az container show --resource-group ${module.resource_group.name} --name ${module.container_instances.container_group_name} --query instanceView.state"
    
    # Docker Commands
    docker_build = "docker build -t ${module.container_registry.login_server}/python-app:latest ."
    docker_push = "docker push ${module.container_registry.login_server}/python-app:latest"
  }
}

# ========================================
# OUTPUTS - INFORMAÇÕES DE DEBUG
# ========================================

output "debug_info" {
  description = "Informações para debug e troubleshooting"
  value = {
    terraform_workspace = terraform.workspace
    resource_prefix     = var.prefix
    environment        = var.tags
  }
}

# ========================================
# OUTPUTS - JENKINS INTEGRATION
# ========================================

output "jenkins_environment_variables" {
  description = "Variáveis de ambiente para configurar no Jenkins"
  value = {
    ACR_LOGIN_SERVER = module.container_registry.login_server
    ACR_USERNAME     = module.container_registry.admin_username
    RESOURCE_GROUP   = module.resource_group.name
    CONTAINER_GROUP  = module.container_instances.container_group_name
    APP_URL         = module.container_instances.app_url
  }
}

output "jenkins_secrets" {
  description = "Secrets que devem ser configurados no Jenkins"
  value = {
    ACR_PASSWORD = "Configure este secret no Jenkins com o valor da senha do ACR"
  }
  sensitive = false
}