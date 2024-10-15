#Specifying AWS Region
aws_region = "ca-central-1"

# Name of KMS Key for signing JWT
jwt_signing_key = "JWTSigningKey"

# Name of KMS Key for encrypting claim set
encryption_key = "EncryptionKey"

#Name of the Lambda role
lambda_role = "LambdaExecutionRole"

#Name Custom policy for KMS access
lambda_policy   = "Customlambda_policy"

# Name of Lambda function for Payment processor
payment_processor = "PaymentProcessorFunction"

# value od secret_key
scret_value = "8f14e45fceea167a5a36dedd4bea2543b9c9f1b256837c6c64e6ef075845c5de"

# Name of aws secret manager
aws_secretmanager = "jwt_secret"

# Tag values for AWS resources
tags = {
  Environment = "Development"
  Project     = "Payment Gateway"
  Owner       = "Anudeep"
}