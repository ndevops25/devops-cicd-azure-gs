# Criar Dockerfile automaticamente
resource "local_file" "dockerfile" {
  content = <<-EOF
FROM python:3.11-alpine

WORKDIR /app

# Instalar Flask
RUN pip install --no-cache-dir flask

# Criar aplicação Python
RUN echo 'from flask import Flask, jsonify
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
    """.format(socket.gethostname(), datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "python-app",
        "version": "1.0",
        "timestamp": datetime.datetime.now().isoformat()
    })

@app.route("/info")
def info():
    return jsonify({
        "app": "Python Flask Application",
        "environment": os.getenv("ENV", "production"),
        "port": os.getenv("PORT", "8000"),
        "hostname": socket.gethostname()
    })

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    app.run(host="0.0.0.0", port=port, debug=False)' > app.py

EXPOSE 8000

CMD ["python", "app.py"]
EOF

  filename = "${path.module}/temp_dockerfile/Dockerfile"
}

# Build e Push da imagem para o ACR
resource "null_resource" "build_and_push_image" {
  depends_on = [
    var.acr_dependency,
    local_file.dockerfile
  ]
  
  provisioner "local-exec" {
    command = <<-EOF
      set -e
      
      echo "🚀 Starting Docker build and push process..."
      
      # Criar diretório temporário se não existir
      mkdir -p ${path.module}/temp_dockerfile
      
      # Ir para o diretório do Dockerfile
      cd ${path.module}/temp_dockerfile
      
      echo "🔑 Logging into ACR..."
      echo "${var.acr_admin_password}" | docker login ${var.acr_login_server} -u ${var.acr_admin_username} --password-stdin
      
      echo "🔨 Building Docker image..."
      docker build -t python-app:latest .
      
      echo "🏷️ Tagging image for ACR..."
      docker tag python-app:latest ${var.acr_login_server}/python-app:latest
      
      echo "📤 Pushing image to ACR..."
      docker push ${var.acr_login_server}/python-app:latest
      
      echo "✅ Image successfully pushed to ACR!"
      
      # Verificar se a imagem foi enviada
      echo "🔍 Verifying image in ACR..."
      az acr repository show-tags --name ${replace(var.acr_login_server, ".azurecr.io", "")} --repository python-app --output table || echo "⚠️ Could not verify, but push completed"
      
      echo "🎉 Build and push process completed!"
    EOF
    
    working_dir = path.module
  }

  # Trigger para re-executar quando necessário
  triggers = {
    acr_server     = var.acr_login_server
    dockerfile_md5 = local_file.dockerfile.content_md5
    always_run     = timestamp()  # Para forçar rebuild sempre que apply
  }
}