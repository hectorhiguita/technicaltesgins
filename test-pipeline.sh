#!/bin/bash

# Script para probar el pipeline localmente antes del despliegue
# Simula las principales validaciones que hará GitHub Actions

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Variables
ECR_REPOSITORY="amrize-ecr-repo"
AWS_REGION="us-east-1"
TEST_PASSED=true

echo "🧪 Iniciando pruebas locales del pipeline..."
echo "════════════════════════════════════════"

# Test 1: Verificar que Docker está disponible
print_step "1. Verificando Docker"
if command -v docker &> /dev/null; then
    if docker --version | grep -q "Docker"; then
        print_success "Docker está disponible"
    else
        print_error "Docker no está funcionando correctamente"
        TEST_PASSED=false
    fi
else
    print_error "Docker no está instalado"
    TEST_PASSED=false
fi

# Test 2: Verificar AWS CLI y credenciales
print_step "2. Verificando AWS CLI y credenciales"
if command -v aws &> /dev/null; then
    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        print_success "AWS CLI configurado (Account: $ACCOUNT_ID)"
    else
        print_error "AWS CLI no está configurado o credenciales inválidas"
        TEST_PASSED=false
    fi
else
    print_error "AWS CLI no está instalado"
    TEST_PASSED=false
fi

# Test 3: Verificar Terraform
print_step "3. Verificando Terraform"
if command -v terraform &> /dev/null; then
    TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_success "Terraform disponible (v$TF_VERSION)"
    
    # Validar configuración de Terraform
    echo "Validando configuración de Terraform..."
    if terraform validate; then
        print_success "Configuración de Terraform válida"
    else
        print_error "Configuración de Terraform inválida"
        TEST_PASSED=false
    fi
else
    print_warning "Terraform no está instalado (opcional para pipeline)"
fi

# Test 4: Verificar estructura de archivos necesarios
print_step "4. Verificando estructura de archivos"

REQUIRED_FILES=(
    "Dockerfile"
    "main.tf"
    ".github/workflows/terraform.yaml"
    "Modules/VPC/vpc.tf"
    "Modules/ECS/ecs.tf"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "Archivo encontrado: $file"
    else
        print_error "Archivo faltante: $file"
        TEST_PASSED=false
    fi
done

# Test 5: Verificar repositorio ECR
print_step "5. Verificando repositorio ECR"
if aws ecr describe-repositories --repository-names "$ECR_REPOSITORY" --region "$AWS_REGION" &> /dev/null; then
    ECR_URI=$(aws ecr describe-repositories --repository-names "$ECR_REPOSITORY" --region "$AWS_REGION" --query 'repositories[0].repositoryUri' --output text)
    print_success "Repositorio ECR encontrado: $ECR_URI"
else
    print_error "Repositorio ECR '$ECR_REPOSITORY' no encontrado"
    print_warning "Puedes crearlo con: aws ecr create-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION"
    TEST_PASSED=false
fi

# Test 6: Probar build de Docker localmente
print_step "6. Probando build de Docker"
if [ "$TEST_PASSED" = true ]; then
    echo "Construyendo imagen Docker localmente..."
    
    # Intentar primero sin sudo
    if docker build -t test-amrize:latest . &> /dev/null; then
        print_success "Build de Docker exitoso"
        docker rmi test-amrize:latest &> /dev/null || true
    # Si falla, intentar con sudo
    elif sudo docker build -t test-amrize:latest . &> /dev/null; then
        print_success "Build de Docker exitoso (requiere sudo)"
        print_warning "Nota: Docker requiere sudo localmente, pero GitHub Actions no lo necesitará"
        sudo docker rmi test-amrize:latest &> /dev/null || true
    else
        print_error "Build de Docker falló"
        echo "Ejecuta 'docker build .' o 'sudo docker build .' para ver detalles del error"
        TEST_PASSED=false
    fi
else
    print_warning "Saltando test de Docker debido a errores previos"
fi

# Test 7: Verificar backend de Terraform (si está configurado)
print_step "7. Verificando backend de Terraform"
if grep -q "backend.*s3" main.tf; then
    BUCKET_NAME=$(grep -A5 "backend.*s3" main.tf | grep -o '"[^"]*amrize[^"]*"' | head -1 | tr -d '"' || echo "")
    
    if [ -n "$BUCKET_NAME" ]; then
        if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
            print_success "Bucket de Terraform state encontrado: $BUCKET_NAME"
        else
            print_warning "Bucket de Terraform state '$BUCKET_NAME' no encontrado o inaccesible"
        fi
    else
        print_warning "No se pudo extraer el nombre del bucket del backend"
    fi
else
    print_warning "Backend remoto de Terraform no configurado (usando local)"
fi

# Test 8: Verificar sintaxis del workflow de GitHub Actions
print_step "8. Verificando workflow de GitHub Actions"
if command -v gh &> /dev/null; then
    if gh workflow list &> /dev/null; then
        print_success "GitHub CLI configurado"
        
        # Verificar sintaxis YAML del workflow
        if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/terraform.yaml'))" 2>/dev/null; then
            print_success "Sintaxis YAML del workflow válida"
        else
            print_error "Sintaxis YAML del workflow inválida"
            TEST_PASSED=false
        fi
    else
        print_warning "GitHub CLI no está autenticado (opcional)"
    fi
else
    print_warning "GitHub CLI no está instalado (opcional)"
fi

# Test 9: Verificar conectividad a servicios AWS necesarios
print_step "9. Verificando conectividad a servicios AWS"

AWS_SERVICES=("ecs" "ecr" "ec2" "elbv2" "iam")

for service in "${AWS_SERVICES[@]}"; do
    case $service in
        "ecs")
            if aws ecs list-clusters --region "$AWS_REGION" &> /dev/null; then
                print_success "Conectividad a ECS verificada"
            else
                print_error "No se puede conectar a ECS"
                TEST_PASSED=false
            fi
            ;;
        "ecr")
            if aws ecr describe-repositories --region "$AWS_REGION" &> /dev/null; then
                print_success "Conectividad a ECR verificada"
            else
                print_error "No se puede conectar a ECR"
                TEST_PASSED=false
            fi
            ;;
        "ec2")
            if aws ec2 describe-vpcs --region "$AWS_REGION" &> /dev/null; then
                print_success "Conectividad a EC2 verificada"
            else
                print_error "No se puede conectar a EC2"
                TEST_PASSED=false
            fi
            ;;
        "elbv2")
            if aws elbv2 describe-load-balancers --region "$AWS_REGION" &> /dev/null; then
                print_success "Conectividad a ELBv2 verificada"
            else
                print_error "No se puede conectar a ELBv2"
                TEST_PASSED=false
            fi
            ;;
        "iam")
            if aws iam get-user &> /dev/null || aws iam get-role --role-name NonExistent &> /dev/null; then
                print_success "Conectividad a IAM verificada"
            else
                print_error "No se puede conectar a IAM"
                TEST_PASSED=false
            fi
            ;;
    esac
done

# Resultados finales
echo
echo "════════════════════════════════════════"
if [ "$TEST_PASSED" = true ]; then
    print_success "🎉 ¡Todos los tests pasaron!"
    echo -e "${GREEN}✅ El pipeline está listo para ejecutarse en GitHub${NC}"
    echo
    echo "Para activar el pipeline:"
    echo "  git add ."
    echo "  git commit -m 'deploy: activar pipeline CI/CD'"
    echo "  git push origin main"
else
    print_error "❌ Algunos tests fallaron"
    echo -e "${RED}⚠️ Corrige los errores antes de hacer push${NC}"
    echo
    echo "Revisa los errores marcados arriba y vuelve a ejecutar este script."
fi
echo "════════════════════════════════════════"

# Exit code basado en el resultado
if [ "$TEST_PASSED" = true ]; then
    exit 0
else
    exit 1
fi
