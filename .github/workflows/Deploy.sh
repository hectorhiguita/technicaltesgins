#!/bin/bash

# Script para construir y subir imagen Docker a ECR
# Uso: ./deploy-to-ecr.sh

set -e

# Variables
aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
AWS_REGION="us-east-1"
ECR_REPOSITORY="amrize-ecr-repo"
IMAGE_TAG="latest"

echo "🚀 Iniciando despliegue a ECR..."

# Obtener información del registro ECR
echo "📋 Obteniendo información del repositorio ECR..."
ECR_URI=$(aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION --query 'repositories[0].repositoryUri' --output text)
echo "📦 Repositorio ECR: $ECR_URI"

# Autenticarse en ECR
echo "🔐 Autenticando con ECR..."
aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_URI

# Construir la imagen Docker
echo "🔨 Construyendo imagen Docker..."
sudo docker build -t $ECR_REPOSITORY:$IMAGE_TAG .

# Etiquetar la imagen para ECR
echo "🏷️ Etiquetando imagen para ECR..."
sudo docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

# Subir la imagen a ECR
echo "⬆️ Subiendo imagen a ECR..."
sudo docker push $ECR_URI:$IMAGE_TAG

echo "✅ ¡Imagen desplegada exitosamente en ECR!"
echo "🌐 URI de la imagen: $ECR_URI:$IMAGE_TAG"

# Opcional: Actualizar task definition de ECS para usar la nueva imagen
echo "🔄 Para actualizar ECS, modifica la imagen en ecs.tf:"
echo "   image = \"$ECR_URI:$IMAGE_TAG\""
