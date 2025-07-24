# Troubleshooting Guide - Terraform Deployment Issues

## 🚨 Problemas Identificados y Soluciones

### 1. **Credenciales AWS no configuradas**
**Error**: `Command produced no output` al ejecutar `aws sts get-caller-identity`

**Causa**: Las credenciales AWS no están configuradas en el sistema.

**Solución**:
```bash
# Opción 1: Configurar AWS CLI (recomendado)
aws configure
# Ingresa: Access Key ID, Secret Key, Region (us-east-1), Output format (json)

# Opción 2: Variables de entorno temporales
export AWS_ACCESS_KEY_ID=your_access_key_here
export AWS_SECRET_ACCESS_KEY=your_secret_key_here
export AWS_DEFAULT_REGION=us-east-1

# Verificar configuración
aws sts get-caller-identity
```

### 2. **Estado de Terraform desincronizado**
**Error**: `Objects have changed outside of Terraform`

**Causa**: Los recursos AWS fueron eliminados manualmente pero Terraform aún los tiene en su estado.

**Solución**:
```bash
# Limpiar completamente el estado local
rm -rf .terraform .terraform.lock.hcl terraform.tfstate*

# Reinicializar sin backend remoto
terraform init
```

### 3. **Problemas con el Backend Remoto S3**
**Error**: `AccessDenied` en operaciones S3/DynamoDB

**Causa**: 
- Permisos insuficientes en AWS
- Bucket S3 o tabla DynamoDB no existen
- AccountID mismatch

**Solución**:
```bash
# Temporalmente comentar el módulo backend en main.tf
# O usar el archivo main-simple.tf que no incluye backend remoto

# Verificar permisos del usuario IAM
aws iam get-user
aws iam list-attached-user-policies --user-name your-username
```

### 4. **AccountID Mismatch**
**Error**: `InvalidParameterException: AccountIDs mismatch`

**Causa**: Los recursos fueron creados con credenciales de una cuenta diferente.

**Solución**:
```bash
# Verificar la cuenta actual
aws sts get-caller-identity

# Limpiar estado y recrear recursos
terraform state rm module.ECS.aws_ecs_cluster.ECS_Amrize
terraform plan
terraform apply
```

## 🛠️ Scripts de Ayuda

### Script de Troubleshooting Automático
```bash
./troubleshoot.sh
```
Este script verificará:
- ✅ Credenciales AWS
- ✅ Archivos de Terraform
- ✅ Módulos requeridos
- ✅ Inicialización de Terraform
- ✅ Validación de configuración
- ✅ Generación de plan

### Script de Configuración de Credenciales
```bash
./configure-aws-credentials.sh
```
Muestra las opciones disponibles para configurar AWS.

## 🚀 Pasos para Deployment Limpio

### 1. Configurar Credenciales
```bash
aws configure
# o usar variables de entorno
```

### 2. Limpiar Estado Anterior
```bash
rm -rf .terraform .terraform.lock.hcl terraform.tfstate*
```

### 3. Usar Configuración Simplificada
```bash
# Opción A: Comentar el módulo backend en main.tf
# Opción B: Usar main-simple.tf
cp main-simple.tf main.tf
```

### 4. Inicializar y Aplicar
```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## 🔧 Verificaciones de Permisos AWS

### Permisos Mínimos Requeridos
El usuario IAM necesita permisos para:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "ecs:*",
                "ecr:*",
                "elasticloadbalancing:*",
                "iam:PassRole",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "logs:*",
                "s3:*",
                "dynamodb:*"
            ],
            "Resource": "*"
        }
    ]
}
```

### Verificar Permisos
```bash
# Verificar identidad actual
aws sts get-caller-identity

# Verificar políticas del usuario
aws iam list-attached-user-policies --user-name $(aws sts get-caller-identity --query User.UserName --output text)

# Verificar límites de servicio
aws service-quotas list-service-quotas --service-code ec2
```

## 📋 Estado Actual del Proyecto

### ✅ Completado
- Pipeline de GitHub Actions configurado
- Módulos de Terraform estructurados
- Dockerfile y configuración ECR
- Scripts de deployment automatizado

### 🔄 En Progreso
- Resolución de problemas de credenciales
- Limpieza de estado de Terraform
- Configuración del backend remoto

### 📝 Próximos Pasos
1. Configurar credenciales AWS válidas
2. Ejecutar script de troubleshooting
3. Aplicar configuración de Terraform
4. Verificar deployment de la aplicación
5. Configurar backend remoto (opcional)

## 🆘 Soporte

Si continúan los problemas:

1. **Verificar región AWS**: Asegúrate de usar `us-east-1`
2. **Verificar límites de cuenta**: Algunos recursos pueden estar limitados
3. **Verificar facturación**: La cuenta AWS debe estar activa
4. **Contactar administrador**: Para permisos adicionales si es cuenta empresarial
