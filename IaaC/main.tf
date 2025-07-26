module "s3_bucket" {
    source = "terraform-aws-modules/s3-bucket/aws"

    bucket = var.bucket_name
    acl    = "private"

    control_object_ownership = true
    object_ownership         = "ObjectWriter"

    versioning = {
        enabled = true
    }

    tags = var.tags
}

module "dynamodb_table" {
    source   = "terraform-aws-modules/dynamodb-table/aws"

    name     = var.dynamodb_table_name
    hash_key = "PK"
    range_key = "SK"

    attributes = [
        {
            name = "PK" 
            type = "S"
        },
        {
            name = "SK"
            type = "S"
        }
    ]

    tags = var.tags
}

resource "aws_ecr_repository" "ecr_repository" {
    name                 = var.ecr_name
    image_tag_mutability = "MUTABLE"

    tags = var.tags
}

resource "aws_iam_role" "lambda_execution_role" {
    name = "lambda-execution-role-${var.environment}"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
    
    tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
    role       = aws_iam_role.lambda_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "dynamodb_policy" {
    name        = "dynamodb-policy-${var.environment}"
    description = "Permite a Lambda leer de DynamoDB"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "dynamodb:GetItem",
                    "dynamodb:Query",
                    "dynamodb:Scan",
                    "dynamodb:BatchGetItem"
                ]
                Resource = module.dynamodb_table.dynamodb_table_arn
            }
        ]
    })
    
    tags = var.tags
}


resource "aws_iam_role_policy_attachment" "dynamodb_policy_attach" {
    role       = aws_iam_role.lambda_execution_role.name
    policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_lambda_function" "main_lambda" {
    function_name = var.lambda_function_name
    role          = aws_iam_role.lambda_execution_role.arn
    package_type  = "Image"
    image_uri     = "${aws_ecr_repository.ecr_repository.repository_url}:latest"
    publish       = true
    timeout       = 450
    
    tags = var.tags
}

resource "aws_api_gateway_rest_api" "pet_shop_api" {
    name        = "api-gateway-pet-shop-${var.environment}"
    description = "API Gateway for Pet Shop Lambda"
    
    endpoint_configuration {
        types = ["REGIONAL"]
    }
    
    tags = var.tags
}

resource "aws_lambda_permission" "api_gateway_invoke" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.main_lambda.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_api_gateway_rest_api.pet_shop_api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "root_any" {
    rest_api_id   = aws_api_gateway_rest_api.pet_shop_api.id
    resource_id   = aws_api_gateway_rest_api.pet_shop_api.root_resource_id
    http_method   = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_method" "root_options" {
    rest_api_id   = aws_api_gateway_rest_api.pet_shop_api.id
    resource_id   = aws_api_gateway_rest_api.pet_shop_api.root_resource_id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_any_integration" {
    rest_api_id = aws_api_gateway_rest_api.pet_shop_api.id
    resource_id = aws_api_gateway_rest_api.pet_shop_api.root_resource_id
    http_method = aws_api_gateway_method.root_any.http_method
    
    integration_http_method = "POST"
    type                   = "AWS_PROXY"
    uri                    = aws_lambda_function.main_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "root_options_integration" {
    rest_api_id = aws_api_gateway_rest_api.pet_shop_api.id
    resource_id = aws_api_gateway_rest_api.pet_shop_api.root_resource_id
    http_method = aws_api_gateway_method.root_options.http_method
    
    integration_http_method = "POST"
    type                   = "AWS_PROXY"
    uri                    = aws_lambda_function.main_lambda.invoke_arn
}

resource "aws_api_gateway_resource" "proxy" {
    rest_api_id = aws_api_gateway_rest_api.pet_shop_api.id
    parent_id   = aws_api_gateway_rest_api.pet_shop_api.root_resource_id
    path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
    rest_api_id   = aws_api_gateway_rest_api.pet_shop_api.id
    resource_id   = aws_api_gateway_resource.proxy.id
    http_method   = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_options" {
    rest_api_id   = aws_api_gateway_rest_api.pet_shop_api.id
    resource_id   = aws_api_gateway_resource.proxy.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_any_integration" {
    rest_api_id = aws_api_gateway_rest_api.pet_shop_api.id
    resource_id = aws_api_gateway_resource.proxy.id
    http_method = aws_api_gateway_method.proxy_any.http_method
    
    integration_http_method = "POST"
    type                   = "AWS_PROXY"
    uri                    = aws_lambda_function.main_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "proxy_options_integration" {
    rest_api_id = aws_api_gateway_rest_api.pet_shop_api.id
    resource_id = aws_api_gateway_resource.proxy.id
    http_method = aws_api_gateway_method.proxy_options.http_method
    
    integration_http_method = "POST"
    type                   = "AWS_PROXY"
    uri                    = aws_lambda_function.main_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "pet_shop_deployment" {
    rest_api_id = aws_api_gateway_rest_api.pet_shop_api.id
    
    depends_on = [
        aws_api_gateway_method.root_any,
        aws_api_gateway_method.root_options,
        aws_api_gateway_method.proxy_any,
        aws_api_gateway_method.proxy_options,
        aws_api_gateway_integration.root_any_integration,
        aws_api_gateway_integration.root_options_integration,
        aws_api_gateway_integration.proxy_any_integration,
        aws_api_gateway_integration.proxy_options_integration,
    ]
}

resource "aws_api_gateway_stage" "pet_shop_stage" {
    deployment_id = aws_api_gateway_deployment.pet_shop_deployment.id
    rest_api_id   = aws_api_gateway_rest_api.pet_shop_api.id
    stage_name    = var.environment
    
    tags = var.tags
}

resource "aws_cloudfront_origin_access_identity" "s3_identity" {
    comment = "CloudFront Origin Access Identity for ${var.bucket_name}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name = module.s3_bucket.s3_bucket_bucket_regional_domain_name
        origin_id   = "s3-origin-${var.bucket_name}"

        s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.s3_identity.cloudfront_access_identity_path
        }
    }

    enabled             = true
    is_ipv6_enabled     = true
    default_root_object = "index.html"

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "s3-origin-${var.bucket_name}"

        forwarded_values {
        query_string = false
        cookies {
            forward = "none"
        }
        }

        viewer_protocol_policy = "redirect-to-https"
    }

    custom_error_response {
        error_code            = 403
        response_code         = 200
        response_page_path    = "/index.html"
        error_caching_min_ttl = 10
    }

    price_class = "PriceClass_100"

    restrictions {
        geo_restriction {
        restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    tags = var.tags
}


resource "aws_s3_bucket_policy" "allow_cloudfront" {
    bucket = module.s3_bucket.s3_bucket_id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
        {
            Sid       = "AllowCloudFrontReadAccess"
            Effect    = "Allow"
            Principal = {
            AWS = aws_cloudfront_origin_access_identity.s3_identity.iam_arn
            }
            Action = ["s3:GetObject"]
            Resource = "${module.s3_bucket.s3_bucket_arn}/*"
        }
        ]
    })
}
