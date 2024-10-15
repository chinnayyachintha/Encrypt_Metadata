import json
import jwt  # PyJWT library for JWT
import boto3
import os

# Initialize the KMS client
kms_client = boto3.client('kms')

# Environment variable for KMS key ID
KMS_KEY_ID = os.environ['KMS_KEY_ID']

def lambda_handler(event, context):
    # Get credit card data from the event
    credit_card_data = {
        'card_number': event['card_number'],
        'expiration_date': event['expiration_date'],
        'cvv': event['cvv'],
    }

    # Create JWT token (you may need to set a secret)
    secret_key = os.environ['JWT_SECRET']  # Store this securely
    token = jwt.encode(credit_card_data, secret_key, algorithm='HS256')

    # Encrypt the token using KMS
    encrypted_token = kms_client.encrypt(
        KeyId=KMS_KEY_ID,
        Plaintext=token.encode('utf-8')
    )['CiphertextBlob']

    # Return the encrypted token
    return {
        'statusCode': 200,
        'body': json.dumps({
            'encrypted_token': encrypted_token.decode('utf-8')  # Convert to base64 string
        })
    }
