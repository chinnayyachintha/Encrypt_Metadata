import os
import json
import boto3
import jwt
import datetime
from base64 import b64encode
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS KMS client
kms_client = boto3.client('kms')

# Environment variables for KMS keys
KMS_SIGNING_KEY_ID = os.environ['KMS_SIGNING_KEY_ID']
KMS_ENCRYPTION_KEY_ID = os.environ['KMS_ENCRYPTION_KEY_ID']

def lambda_handler(event, context):
    """
    Main Lambda handler function to encrypt credit card metadata 
    and generate a signed JWT.
    """
    try:
        # Validate input parameters
        credit_card_data = event.get('credit_card_data')
        session_id = event.get('session_id')
        idempotency_key = event.get('idempotency_key')

        if not all([credit_card_data, session_id, idempotency_key]):
            logger.error("Missing required parameters")
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Missing required parameters'})
            }

        # Combine metadata for encryption
        metadata = f"{session_id},{idempotency_key},{credit_card_data}"

        # Step 1: Encrypt the metadata using KMS
        encrypted_metadata = encrypt_metadata(metadata)
        logger.info("Metadata encryption successful")

        # Step 2: Generate and sign the JWT
        jwt_token = generate_signed_jwt(encrypted_metadata)
        logger.info("JWT generation and signing successful")

        # Return the signed JWT
        return {
            'statusCode': 200,
            'body': json.dumps({'jwt': jwt_token})
        }

    except Exception as e:
        logger.error(f"An error occurred: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'An internal server error occurred'})
        }

def encrypt_metadata(metadata):
    """
    Encrypt metadata using AWS KMS.
    """
    try:
        # Encrypt the metadata with KMS
        response = kms_client.encrypt(
            KeyId=KMS_ENCRYPTION_KEY_ID,
            Plaintext=metadata.encode('utf-8')
        )
        # Get the encrypted data (base64 encoded for JWT inclusion)
        encrypted_data = b64encode(response['CiphertextBlob']).decode('utf-8')
        return encrypted_data
    except Exception as e:
        logger.error(f"Error encrypting metadata: {str(e)}")
        raise

def generate_signed_jwt(encrypted_metadata):
    """
    Create and sign a JWT using the KMS private key.
    """
    try:
        now = datetime.datetime.utcnow()
        payload = {
            'iss': 'payment-processor-env',  # Unique issuer for payment processing
            'aud': 'https://payment-gateway.example.com',  # Payment gateway URL
            'iat': now,
            'exp': now + datetime.timedelta(minutes=15),
            'meta_data': encrypted_metadata
        }

        # JWT headers
        headers = {
            "alg": "RS256",
            "typ": "JWT"
        }

        # Create JWT message to be signed
        message = jwt.encode(payload, "", algorithm='RS256', headers=headers).split(".")[0] + "." + \
                  jwt.encode(payload, "", algorithm='RS256', headers=headers).split(".")[1]

        # Sign the JWT using KMS
        response = kms_client.sign(
            KeyId=KMS_SIGNING_KEY_ID,
            Message=message.encode('utf-8'),
            MessageType='RAW',
            SigningAlgorithm='RSASSA_PKCS1_V1_5_SHA_256'
        )

        # Generate JWT signature
        signature = b64encode(response['Signature']).decode('utf-8')

        # Construct the final JWT token
        jwt_token = f"{message}.{signature}"
        return jwt_token

    except Exception as e:
        logger.error(f"Error generating signed JWT: {str(e)}")
        raise
