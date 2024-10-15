# KMS Key for JWT Signing
resource "aws_kms_key" "jwt_signing_key" {
  description              = "KMS Key for signing JWT"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_2048"

  tags = merge(
    {
      Name = var.jwt_signing_key
    },
    var.tags
  )
}

# KMS Alias for JWT Signing Key
resource "aws_kms_alias" "jwt_signing_key_alias" {
  name          = "alias/${var.jwt_signing_key}"
  target_key_id = aws_kms_key.jwt_signing_key.id
}

# KMS Key for Claim Set Encryption
resource "aws_kms_key" "encryption_key" {
  description = "KMS Key for encrypting claim set"
  key_usage   = "ENCRYPT_DECRYPT"

  tags = merge(
    {
      Name = var.encryption_key
    },
    var.tags
  )
}

# KMS Alias for Claim Set Encryption Key
resource "aws_kms_alias" "encryption_key_alias" {
  name          = "alias/${var.encryption_key}"
  target_key_id = aws_kms_key.encryption_key.id
}


# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })

  tags = merge(
    {
      Name = var.lambda_role
    },
    var.tags
  )
}


# Custom IAM Policy 
resource "aws_iam_policy" "lambda_policy" {
  name        = "LambdaPolicy"
  description = "Policy for Lambda execution and KMS access"

  # Define combined policy
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:Sign"
        ],
        Resource = "*"  
      },
      {
        Effect = "Allow",
        Action = "secretsmanager:GetSecretValue",
        Resource = aws_secretsmanager_secret.jwt_secret.arn
      },
      {
        Effect = "Allow",
        Action = "logs:*",
        Resource = "*"
      }
    ]
  })

  tags = merge(
    {
      Name = var.lambda_policy  
    },
    var.tags 
  )
}


# Attach the custom policy to the IAM role
resource "aws_iam_role_policy_attachment" "custom_kms_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.custom_kms_policy.arn
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name        = var.aws_secretmanager
  description = "JWT Secret for Lambda Function"
}

resource "aws_secretsmanager_secret_version" "jwt_secret_value" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = var.scret_value
}

# Lambda Function
resource "aws_lambda_function" "payment_processor" {
  filename      = "encrypt/lambda_function.zip" # Path to your deployment package
  function_name = "Encrypt_PaymentProcessorFunction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      KMS_SIGNING_KEY_ID    = aws_kms_key.jwt_signing_key.id
      KMS_ENCRYPTION_KEY_ID = aws_kms_key.encryption_key.id
      JWT_SECRET            = aws_secretsmanager_secret.jwt_secret.secret_string
    }
  }

  # Optional: Define memory size and timeout settings
  memory_size = 128 # Size in MB
  timeout     = 30  # Timeout in seconds

  tags = merge(
    {
      Name = var.payment_processor
    },
    var.tags
  )
}
