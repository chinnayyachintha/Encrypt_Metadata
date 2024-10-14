variable "aws_region" {
  type        = string
  description = "Specifying name of region"
}

variable "jwt_signing_key" {
  type        = string
  description = "Name of KMS Key for signing JWT"
}

variable "encryption_key" {
  type        = string
  description = "Name of KMS Key for encrypting claim set"
}

variable "lambda_role" {
  type        = string
  description = "Name of lambda role"
}

variable "custom_kms_policy" {
  type        = string
  description = "Name Custom policy for KMS access"
}

variable "payment_processor" {
  type        = string
  description = "Name of the Lambda Function for Payment Processor"
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
}