# GitHub Secrets Configuration Guide

Este archivo contiene la configuración necesaria para los GitHub Secrets que debe configurar en su repositorio.

## Configuración de Secrets en GitHub

Vaya a: `Settings > Secrets and variables > Actions > New repository secret`

### Required Secrets:

```
AWS_ACCESS_KEY_ID
Valor: your_aws_access_key_id_here
Descripción: Clave de acceso de AWS para el usuario IAM

AWS_SECRET_ACCESS_KEY
Valor: your_aws_secret_access_key_here
Descripción: Clave secreta de AWS para el usuario IAM

TF_STATE_BUCKET_NAME
Valor: amrizetesting-test-terraform-state
Descripción: Nombre del bucket S3 para el estado de Terraform

TF_STATE_KEY_PREFIX
Valor: terraform-state
Descripción: Prefijo para las claves del estado de Terraform
```

## Permisos IAM Requeridos

El usuario IAM debe tener los siguientes permisos:

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
                "iam:*",
                "logs:*",
                "s3:*",
                "dynamodb:*"
            ],
            "Resource": "*"
        }
    ]
}
```

## Configuración de Variables de Entorno (opcional)

En `Settings > Secrets and variables > Actions > Variables`:

```
AWS_DEFAULT_REGION
Valor: us-east-1
Descripción: Región por defecto de AWS
```

## Verificación

Una vez configurados los secrets, puede verificar que el pipeline funciona:

1. Haga un push a la rama `main`
2. Vaya a la pestaña `Actions` en GitHub
3. Observe el progreso del workflow "Complete Infrastructure and Application Deployment"

## Troubleshooting

Si el pipeline falla:

1. **Error de autenticación AWS**: Verifique que los secrets AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY sean correctos
2. **Error de bucket S3**: Asegúrese de que el bucket TF_STATE_BUCKET_NAME existe y es accesible
3. **Error de permisos**: Verifique que el usuario IAM tenga todos los permisos necesarios
4. **Error de ECR**: El pipeline creará el repositorio ECR automáticamente en el primer run

## Pipeline Features

El pipeline incluye:
- ✅ Build automático de imagen Docker
- ✅ Push a ECR con tagging por commit SHA
- ✅ Despliegue de infraestructura Terraform
- ✅ Actualización automática de servicios ECS
- ✅ Verificación de salud de la aplicación
- ✅ Comentarios en PR con planes de Terraform
