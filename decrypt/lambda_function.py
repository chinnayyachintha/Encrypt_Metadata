import json
import boto3
import os
import base64
import jwt  # Import PyJWT library for JWT

# Initialize the KMS client
kms_client = boto3.client('kms')

# Environment variable for KMS key ID
KMS_KEY_ID = os.environ['KMS_ENCRYPTION_KEY_ID']

def lambda_handler(event, context):
    # Get the Base64-encoded encrypted token from the event
    encrypted_token_base64 = event['encrypted_token']
    
    # Decode the Base64 string to get the encrypted token
    encrypted_token = base64.b64decode(encrypted_token_base64)

    # Decrypt the token using KMS
    decrypted_response = kms_client.decrypt(
        CiphertextBlob=encrypted_token
    )
    
    # Get the plaintext token (JWT)
    plaintext_token = decrypted_response['Plaintext'].decode('utf-8')

    # Decode the JWT to get the credit card data
    secret_key = os.environ['JWT_SECRET']  # Ensure you have the same secret key
    credit_card_data = jwt.decode(plaintext_token, secret_key, algorithms=['HS256'])

    # Return the credit card data
    return {
        'statusCode': 200,
        'body': json.dumps({
            'credit_card_data': credit_card_data  # Return the original credit card data
        })
    }
