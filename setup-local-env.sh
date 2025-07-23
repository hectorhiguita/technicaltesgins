#!/bin/bash

# Configuración de secrets para desarrollo local
# Este script ayuda a exportar las variables de entorno necesarias para el desarrollo local

echo "🔧 Configuración de variables de entorno para desarrollo local"
echo "============================================================"

# Verificar si existen las credenciales de AWS
if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
    echo "⚠️  AWS_ACCESS_KEY_ID no está configurado"
    echo "   Ejecute: export AWS_ACCESS_KEY_ID=your_access_key"
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
    echo "⚠️  AWS_SECRET_ACCESS_KEY no está configurado"
    echo "   Ejecute: export AWS_SECRET_ACCESS_KEY=your_secret_key"
fi

if [[ -z "$AWS_DEFAULT_REGION" ]]; then
    echo "ℹ️  Configurando AWS_DEFAULT_REGION=us-east-1"
    export AWS_DEFAULT_REGION=us-east-1
fi

# Variables específicas del proyecto
export ECR_REPOSITORY=amrize-ecr-repo
export IMAGE_TAG=local-$(date +%s)

echo ""
echo "✅ Variables configuradas:"
echo "   AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
echo "   ECR_REPOSITORY: $ECR_REPOSITORY"
echo "   IMAGE_TAG: $IMAGE_TAG"

echo ""
echo "🚀 Para hacer un build local:"
echo "   docker build -t $ECR_REPOSITORY:$IMAGE_TAG ."
echo ""
echo "🔄 Para desplegar manualmente:"
echo "   ./deploy-to-ecr.sh"
echo ""
echo "🏗️  Para aplicar Terraform:"
echo "   terraform plan"
echo "   terraform apply"
