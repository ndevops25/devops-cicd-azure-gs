# Criar aplicação Python separadamente
resource "local_file" "python_app" {
  content = <<-EOF
from flask import Flask, jsonify
import os
import socket
import datetime

app = Flask(__name__)

@app.route("/")
def hello():
    return """
    <h1>🐍 Python App Running!</h1>
    <p><strong>Status:</strong> ✅ Healthy</p>
    <p><strong>Environment:</strong> Azure Container Instances</p>
    <p><strong>Hostname:</strong> {}</p>
    <p><strong>Time:</strong> {}</p>
    <p><strong>Version:</strong> 1.0</p>
    <hr>
    <p><small>Built with Terraform + ACR + ACI</small></p>
    """.format(socket.gethostname(), datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "python-app",
        "version": "1.0",
        "timestamp": datetime.datetime.now().isoformat(),
        "hostname": socket.gethostname()
    })

@app.route("/info")
def info():
    return jsonify({
        "app": "Python Flask Application",
        "environment": os.getenv("ENV", "production"),
        "port": os.getenv("PORT", "8000"),
        "hostname": socket.gethostname(),
        "python_version": "3.11"
    })

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    print(f"🚀 Starting Flask app on port {port}")
    app.run(host="0.0.0.0", port=port, debug=False)
EOF

  filename = "${path.module}/temp_build/app.py"
}

# Criar Dockerfile separadamente
resource "local_file" "dockerfile" {
  content = <<-EOF
FROM python:3.11-alpine

WORKDIR /app

# Instalar dependências
RUN pip install --no-cache-dir flask

# Copiar aplicação
COPY app.py .

# Expor porta
EXPOSE 8000

# Comando para executar
CMD ["python", "app.py"]
EOF

  filename = "${path.module}/temp_build/Dockerfile"
}

# Build e Push da imagem para o ACR
resource "null_resource" "build_and_push_image" {
  depends_on = [
    var.acr_dependency,
    local_file.python_app,
    local_file.dockerfile
  ]
  
  provisioner "local-exec" {
    command = <<-EOF
      set -e
      
      echo "🔍 Verificando pré-requisitos..."
      
      # Verificar se Docker está rodando
      if ! docker info > /dev/null 2>&1; then
          echo "❌ Docker não está rodando ou não está instalado"
          echo "📝 Por favor, inicie o Docker Desktop e tente novamente"
          exit 1
      fi
      
      # Verificar se Azure CLI está instalado
      if ! command -v az &> /dev/null; then
          echo "❌ Azure CLI não está instalado"
          exit 1
      fi
      
      echo "✅ Pré-requisitos OK"
      
      # Criar diretório se não existir e navegar
      mkdir -p modules/container-instances/temp_build
      cd modules/container-instances/temp_build
      
      echo "📋 Arquivos no diretório:"
      ls -la
      
      echo "🔑 Fazendo login no ACR com Azure CLI..."
      az acr login --name ${replace(var.acr_login_server, ".azurecr.io", "")}
      
      echo "🔨 Building imagem Docker..."
      docker build -t python-app:local .
      
      echo "🏷️ Tagging imagem para ACR..."
      docker tag python-app:local ${var.acr_login_server}/python-app:latest
      
      echo "📤 Fazendo push para ACR..."
      docker push ${var.acr_login_server}/python-app:latest
      
      echo "🔍 Verificando imagem no ACR..."
      az acr repository show-tags --name ${replace(var.acr_login_server, ".azurecr.io", "")} --repository python-app --output table || echo "⚠️ Não foi possível verificar, mas push concluído"
      
      echo "🧹 Limpando imagem local..."
      docker rmi python-app:local ${var.acr_login_server}/python-app:latest || true
      
      echo "✅ Build e push concluídos com sucesso!"
      echo "🎯 Imagem disponível em: ${var.acr_login_server}/python-app:latest"
    EOF
    
    working_dir = "."
  }

  # Triggers APENAS para mudanças reais nos arquivos
  triggers = {
    acr_server     = var.acr_login_server
    python_app_md5 = local_file.python_app.content_md5
    dockerfile_md5 = local_file.dockerfile.content_md5
    # timestamp removido! ← Esta era a causa do problema
  }
}