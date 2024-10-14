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


# Custom IAM Policy for KMS Access
resource "aws_iam_policy" "custom_kms_policy" {
  name        = "CustomKMSPolicy"
  description = "Custom policy for KMS access"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:Sign"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = merge(
    {
      Name = var.custom_kms_policy
    },
    var.tags
  )
}

# Attach the custom policy to the IAM role
resource "aws_iam_role_policy_attachment" "custom_kms_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.custom_kms_policy.arn
}


# Lambda Function
resource "aws_lambda_function" "payment_processor" {
  filename      = "payment_processor_lambda/encryptdata_lambda_function.zip" # Path to your deployment package
  function_name = "PaymentProcessorFunction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "encryptdata_lambda_function.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      KMS_SIGNING_KEY_ID    = aws_kms_key.jwt_signing_key.id
      KMS_ENCRYPTION_KEY_ID = aws_kms_key.encryption_key.id
    }
  }

  # Optional: Define memory size and timeout settings
  memory_size = 128 # Size in MB
  timeout     = 10  # Timeout in seconds

  tags = merge(
    {
      Name = var.payment_processor
    },
    var.tags
  )
}
