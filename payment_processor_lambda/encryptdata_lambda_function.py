import json
import boto3
import os
import base64  # Import base64 for encoding

kms_client = boto3.client('kms')

def lambda_handler(event, context):
    # Extract metadata from the incoming event
    metadata = event.get('metadata')
    if not metadata:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Missing required input: metadata'})
        }
    
    # Get KMS encryption key ID from environment variable
    kms_encryption_key_id = os.environ.get('KMS_ENCRYPTION_KEY_ID')
    if not kms_encryption_key_id:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'KMS_ENCRYPTION_KEY_ID environment variable is not set'})
        }

    try:
        # Encrypt the metadata using KMS
        response = kms_client.encrypt(
            KeyId=kms_encryption_key_id,
            Plaintext=json.dumps(metadata).encode('utf-8')  # Ensure this is UTF-8 encoded
        )

        encrypted_data = response['CiphertextBlob']

        # Encode the encrypted data in Base64
        encrypted_data_base64 = base64.b64encode(encrypted_data).decode('utf-8')

        # Send back the encrypted metadata (base64 encoded)
        return {
            'statusCode': 200,
            'body': json.dumps({
                'encrypted_metadata': encrypted_data_base64  # Now safely encoded
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'An error occurred during encryption', 'error': str(e)})
        }
