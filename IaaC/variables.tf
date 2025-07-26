variable "aws_region" {
    description = "La región de AWS donde se crearán los recursos"
    type        = string
    default     = "us-east-1"
}

variable "bucket_name" {
    description = "Nombre del bucket S3"
    type        = string
}

variable "environment" {
    description = "Ambiente de despliegue (dev, staging, prod)"
    type        = string
    default     = "dev"
}

variable "tags" {
    description = "Tags comunes para todos los recursos"
    type        = map(string)
    default     = {}
}

variable "dynamodb_table_name" {
    description = "Nombre de la tabla DynamoDB"
    type        = string
}

variable "ecr_name" {
    description = "Nombre del repositorio ECR"
    type        = string
    default     = "ecr-repository-modernizacion"
}

variable "lambda_function_name" {
    description = "Nombre de la función Lambda"
    type        = string
    default     = "main-lambda-function"
}