# Output for KMS Signing Key ID
output "kms_signing_key_id" {
  description = "The KMS Key ID for JWT signing"
  value       = aws_kms_key.jwt_signing_key.id
}

# Output for KMS Encryption Key ID
output "kms_encryption_key_id" {
  description = "The KMS Key ID for encrypting claim set"
  value       = aws_kms_key.encryption_key.id
}

# Outputs to reference the combined policy
output "custom_lambda_policy" {
  value       = aws_iam_policy.lambda_policy.arn
  description = "The ARN of the Combined Lambda and KMS Policy"
}
