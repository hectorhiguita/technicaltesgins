#!/bin/bash

# Script para configurar secretos de GitHub para el pipeline de CI/CD
# Requiere GitHub CLI (gh) instalado y autenticado

set -e

echo "🔐 Configurando secretos de GitHub para el pipeline CI/CD..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con color
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que gh CLI está instalado
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) no está instalado. Instálalo desde: https://cli.github.com/"
    exit 1
fi

# Verificar autenticación
if ! gh auth status &> /dev/null; then
    print_error "No estás autenticado con GitHub CLI. Ejecuta: gh auth login"
    exit 1
fi

print_status "Verificando repositorio actual..."
REPO_INFO=$(gh repo view --json nameWithOwner,name,owner)
REPO_FULL_NAME=$(echo "$REPO_INFO" | jq -r '.nameWithOwner')
REPO_NAME=$(echo "$REPO_INFO" | jq -r '.name')
REPO_OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')

print_success "Repositorio detectado: $REPO_FULL_NAME"

# Función para obtener credenciales AWS
get_aws_credentials() {
    print_status "Obteniendo credenciales AWS actuales..."
    
    # Intentar obtener desde AWS CLI
    if command -v aws &> /dev/null; then
        AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id 2>/dev/null || echo "")
        AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key 2>/dev/null || echo "")
        AWS_DEFAULT_REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")
    fi
    
    # Si no se pudieron obtener, pedir manualmente
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        echo -n "Ingresa tu AWS Access Key ID: "
        read -r AWS_ACCESS_KEY_ID
    fi
    
    if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo -n "Ingresa tu AWS Secret Access Key: "
        read -rs AWS_SECRET_ACCESS_KEY
        echo
    fi
    
    if [ -z "$AWS_DEFAULT_REGION" ]; then
        echo -n "Ingresa tu región AWS (default: us-east-1): "
        read -r AWS_DEFAULT_REGION
        AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
    fi
}

# Función para obtener configuración del backend de Terraform
get_terraform_backend_config() {
    print_status "Configurando backend de Terraform..."
    
    # Valores por defecto basados en la configuración actual
    DEFAULT_BUCKET="amrize-terraform-state-bucket"
    DEFAULT_KEY_PREFIX="terraform-state"
    
    echo -n "Nombre del bucket S3 para Terraform state (default: $DEFAULT_BUCKET): "
    read -r TF_STATE_BUCKET_NAME
    TF_STATE_BUCKET_NAME=${TF_STATE_BUCKET_NAME:-$DEFAULT_BUCKET}
    
    echo -n "Prefijo de la key para Terraform state (default: $DEFAULT_KEY_PREFIX): "
    read -r TF_STATE_KEY_PREFIX
    TF_STATE_KEY_PREFIX=${TF_STATE_KEY_PREFIX:-$DEFAULT_KEY_PREFIX}
}

# Función para configurar un secreto
set_secret() {
    local secret_name=$1
    local secret_value=$2
    local description=$3
    
    if [ -z "$secret_value" ]; then
        print_warning "Valor vacío para $secret_name, saltando..."
        return
    fi
    
    print_status "Configurando secreto: $secret_name"
    if echo "$secret_value" | gh secret set "$secret_name" --repo "$REPO_FULL_NAME"; then
        print_success "✅ $secret_name configurado"
    else
        print_error "❌ Error configurando $secret_name"
        return 1
    fi
}

# Main execution
main() {
    echo "════════════════════════════════════════"
    echo "🚀 CONFIGURACIÓN DE SECRETOS DE GITHUB  "
    echo "════════════════════════════════════════"
    echo
    
    # Obtener credenciales AWS
    get_aws_credentials
    
    # Obtener configuración del backend
    get_terraform_backend_config
    
    print_status "Configurando secretos en GitHub..."
    
    # Configurar secretos uno por uno
    set_secret "AWS_ACCESS_KEY_ID" "$AWS_ACCESS_KEY_ID" "AWS Access Key ID para autenticación"
    set_secret "AWS_SECRET_ACCESS_KEY" "$AWS_SECRET_ACCESS_KEY" "AWS Secret Access Key para autenticación"
    set_secret "TF_STATE_BUCKET_NAME" "$TF_STATE_BUCKET_NAME" "Nombre del bucket S3 para Terraform state"
    set_secret "TF_STATE_KEY_PREFIX" "$TF_STATE_KEY_PREFIX" "Prefijo para las keys de Terraform state"
    
    echo
    print_success "🎉 ¡Configuración completada!"
    echo
    echo "════════════════════════════════════════"
    echo "📋 RESUMEN DE CONFIGURACIÓN"
    echo "════════════════════════════════════════"
    echo "• Repositorio: $REPO_FULL_NAME"
    echo "• Región AWS: $AWS_DEFAULT_REGION"
    echo "• Bucket Terraform: $TF_STATE_BUCKET_NAME"
    echo "• Key Prefix: $TF_STATE_KEY_PREFIX"
    echo
    echo "🚀 El pipeline está listo para usar!"
    echo "   Para activarlo, haz push a la rama 'main'"
    echo
    echo "🔗 Puedes ver los secretos en:"
    echo "   https://github.com/$REPO_FULL_NAME/settings/secrets/actions"
}

# Ejecutar solo si es llamado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
