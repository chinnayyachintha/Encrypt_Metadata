#Specifying AWS Region
aws_region = "ca-central-1"

# Name of KMS Key for signing JWT
jwt_signing_key = "JWTSigningKey"

# Name of KMS Key for encrypting claim set
encryption_key = "EncryptionKey"

#Name of the Lambda role
lambda_role = "LambdaExecutionRole"

#Name Custom policy for KMS access
custom_kms_policy = "CustomKMSPolicy"

# Name of Lambda function for Payment processor
payment_processor = "PaymentProcessorFunction"

# Tag values for AWS resources
tags = {
  Environment = "Development"
  Project     = "Payment Gateway"
  Owner       = "Anudeep"
}