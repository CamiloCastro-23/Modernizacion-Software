# Configuración para el despliegue
aws_region  = "us-east-1"
bucket_name = "s3-bucket-modernizacion"
environment = "dev"

tags = {
  tag-modernizacion     = "tag-modernizacion"
}

dynamodb_table_name = "dynamodb-table-modernizacion"

ecr_name = "ecr-repository-modernizacion"

lambda_function_name = "lambda-function-modernizacion"
