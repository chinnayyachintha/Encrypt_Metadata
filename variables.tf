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

variable "lambda_policy" {
  type        = string
  description = "Name Custom policy for KMS access"
}

variable "payment_processor" {
  type        = string
  description = "Name of the Lambda Function for Payment Processor"
}

variable "secret_key" {
  description = "Name of the secret key"
  type        = string
}

variable "aws_secretmanager" {
  type        = string
  description = "Name od aws secret manager for to store jwt secret key"
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
}