output "bucket_id" {
    description = "ID del bucket S3"
    value       = module.s3_bucket.s3_bucket_id
}

output "bucket_arn" {
    description = "ARN del bucket S3"
    value       = module.s3_bucket.s3_bucket_arn
}

output "bucket_domain_name" {
    description = "Nombre de dominio del bucket"
    value       = module.s3_bucket.s3_bucket_bucket_domain_name
}

output "bucket_regional_domain_name" {
    description = "Nombre de dominio regional del bucket"
    value       = module.s3_bucket.s3_bucket_bucket_regional_domain_name
}

output "bucket_region" {
    description = "Región del bucket"
    value       = module.s3_bucket.s3_bucket_region
}

output "bucket_hosted_zone_id" {
    description = "The Route 53 Hosted Zone ID for this bucket's region"
    value       = module.s3_bucket.s3_bucket_hosted_zone_id
}

output "dynamodb_table_name" {
    description = "Nombre de la tabla DynamoDB"
    value       = module.dynamodb_table.dynamodb_table_id
}

output "dynamodb_table_arn" {
    description = "ARN de la tabla DynamoDB"
    value       = module.dynamodb_table.dynamodb_table_arn
}

output "lambda_function_name" {
    description = "Nombre de la función Lambda"
    value       = aws_lambda_function.main_lambda.function_name
}

output "lambda_function_arn" {
    description = "ARN de la función Lambda"
    value       = aws_lambda_function.main_lambda.arn
}

output "ecr_repository_url" {
    description = "URL del repositorio ECR"
    value       = aws_ecr_repository.ecr_repository.repository_url
}