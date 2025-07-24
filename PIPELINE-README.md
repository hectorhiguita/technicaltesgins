# 🚀 Pipeline CI/CD para Amrize

Este repositorio contiene un pipeline completo de CI/CD que automatiza el despliegue de una aplicación containerizada en AWS usando GitHub Actions, Terraform, Docker y ECS.

## 📋 Resumen del Pipeline

El pipeline consta de **5 jobs principales**:

1. **🚀 Build & Push Docker Image to ECR** - Construye y sube la imagen Docker a ECR
2. **🏗️ Terraform Infrastructure Deployment** - Despliega/actualiza la infraestructura
3. **🔄 Update ECS Service** - Actualiza el servicio ECS con la nueva imagen
4. **✅ Verify Deployment** - Verifica que el despliegue sea exitoso
5. **🧹 Cleanup on Failure** - Maneja errores y realiza rollback automático

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  GitHub Actions │───▶│   Amazon ECR    │───▶│   Amazon ECS    │
│   (CI/CD)       │    │ (Container Repo)│    │   (Containers)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         ▼                                              ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Terraform     │───▶│      VPC        │───▶│  Load Balancer  │
│ (Infrastructure)│    │   (Network)     │    │     (ALB)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Componentes de AWS:
- **VPC**: Red privada virtual con subnets públicas y privadas
- **ECS Fargate**: Servicio de contenedores serverless
- **ECR**: Registro de contenedores Docker
- **ALB**: Application Load Balancer para distribución de tráfico
- **S3 + DynamoDB**: Backend remoto para Terraform state
- **CloudWatch**: Logs y monitoreo

## 🚀 Configuración Inicial

### 1. Prerrequisitos

- ✅ Cuenta de AWS con permisos administrativos
- ✅ GitHub CLI instalado (`gh`)
- ✅ Terraform instalado (opcional para testing local)
- ✅ Docker instalado (opcional para testing local)

### 2. Configurar Secretos de GitHub

**Opción A: Script Automático (Recomendado)**
```bash
# Ejecutar el script de configuración
./setup-github-secrets.sh
```

**Opción B: Manual**

Ve a: `https://github.com/TU_USUARIO/TU_REPO/settings/secrets/actions`

Configura estos secretos:
- `AWS_ACCESS_KEY_ID`: Tu AWS Access Key
- `AWS_SECRET_ACCESS_KEY`: Tu AWS Secret Key
- `TF_STATE_BUCKET_NAME`: Nombre del bucket S3 para Terraform state
- `TF_STATE_KEY_PREFIX`: Prefijo para organizar los archivos de state

### 3. Verificar Configuración

```bash
# Verificar que los módulos están correctos
terraform validate

# Verificar conectividad AWS
aws sts get-caller-identity
```

## 🔄 Flujo de Trabajo

### Para Pull Requests:
1. Se ejecuta build de Docker
2. Se ejecuta plan de Terraform
3. Se comenta el plan en el PR
4. **NO** se despliega

### Para Push a `main`:
1. **Build & Push**: Construye imagen Docker y la sube a ECR
2. **Infrastructure**: Actualiza infraestructura con Terraform
3. **ECS Update**: Actualiza servicio ECS con nueva imagen
4. **Verification**: Verifica que la aplicación responda correctamente
5. **Cleanup**: Si algo falla, hace rollback automático

## 📱 Uso del Pipeline

### Despliegue Automático
```bash
# Hacer cambios al código
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main
# ¡El pipeline se ejecuta automáticamente!
```

### Monitoreo del Despliegue
1. Ve a la pestaña "Actions" en GitHub
2. Observa el progreso en tiempo real
3. Recibe notificaciones de éxito/fallo

### Acceso a la Aplicación
Una vez completado el despliegue:
- URL de la aplicación se muestra en el log del pipeline
- También disponible en los outputs de Terraform

## 🛠️ Personalización

### Variables de Entorno
Modifica estas variables en `.github/workflows/terraform.yaml`:

```yaml
env:
  AWS_DEFAULT_REGION: us-east-1      # Región AWS
  ECR_REPOSITORY: amrize-ecr-repo    # Nombre del repositorio ECR
  IMAGE_TAG: ${{ github.sha }}       # Tag de la imagen
```

### Modificar la Aplicación
1. Edita el `Dockerfile` para cambiar la aplicación base
2. Modifica `public-html/index.html` para el contenido web
3. El pipeline detectará automáticamente los cambios

### Configuración de Infraestructura
- **VPC**: Modifica `Modules/VPC/vpc.tf`
- **ECS**: Modifica `Modules/ECS/ecs.tf`
- **Variables**: Ajusta `terraform.tfvars`

## 🔍 Troubleshooting

### Error: "Repository does not exist"
```bash
# Verificar que el repositorio ECR existe
aws ecr describe-repositories --repository-names amrize-ecr-repo
```

### Error: "Service does not exist"
```bash
# Verificar que el cluster y servicio ECS existen
aws ecs describe-clusters --clusters amrize-ecs-cluster
aws ecs describe-services --cluster amrize-ecs-cluster --services apache-service
```

### Error: "Access Denied"
- Verificar que las credenciales AWS tienen los permisos necesarios
- Verificar que los secretos de GitHub están configurados correctamente

### Pipeline Falla en Terraform
1. Revisa los logs de Terraform en el job "Terraform Infrastructure Deployment"
2. Verifica que el backend S3 existe y es accesible
3. Ejecuta `terraform plan` localmente para debugging

### Aplicación No Responde
1. Verifica que el ALB esté saludable en la consola AWS
2. Revisa los logs de ECS en CloudWatch
3. Verifica que los security groups permiten tráfico en el puerto 80

## 📊 Monitoreo y Logs

### CloudWatch Logs
- **Grupo de logs**: `/ecs/apache`
- **Stream**: Cada contenedor tiene su propio stream

### Métricas de ECS
- **CPU y Memoria**: Métricas automáticas en CloudWatch
- **Health Checks**: ALB verifica salud de los targets

### ALB Access Logs
Puedes habilitar access logs del ALB modificando la configuración en Terraform.

## 🔐 Seguridad

### Mejores Prácticas Implementadas:
- ✅ Credenciales AWS almacenadas como secretos de GitHub
- ✅ Terraform state almacenado remotamente en S3 con DynamoDB locking
- ✅ Subnets privadas para ECS tasks
- ✅ Security groups restrictivos
- ✅ IAM roles con permisos mínimos necesarios

### Recomendaciones Adicionales:
- 🔄 Rotar credenciales AWS regularmente
- 📝 Revisar logs de acceso periódicamente
- 🛡️ Configurar alertas de CloudWatch para eventos anómalos

## 🆘 Soporte

Para problemas o preguntas:
1. Revisa los logs del pipeline en GitHub Actions
2. Verifica la configuración de AWS en la consola
3. Consulta la documentación de Terraform para módulos específicos

## 📝 Changelog

### v1.0.0 (Actual)
- ✅ Pipeline completo de CI/CD
- ✅ Integración con ECR, ECS, ALB
- ✅ Rollback automático en caso de fallo
- ✅ Verificación de salud post-despliegue
- ✅ Infraestructura como código con Terraform

---

🚀 **¡Happy Deploying!** 🚀
