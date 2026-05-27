#!/bin/bash
# Step 4: Store certificates in AWS Secrets Manager
# Reference: https://integ.www.docs.aws.a2z.com/mgn/latest/ug/fsx-ontap.html#fsx-ontap-step4-store-certs
set -e
source "$(dirname "$0")/helpers.sh"
load_config

CERT_DIR="$(dirname "$0")/certs"

# Read cert and key content
CERT_CONTENT=$(cat "$CERT_DIR/fsx-mgn-client.crt")
KEY_CONTENT=$(cat "$CERT_DIR/fsx-mgn-client.key")

echo "=== Creating secret in Secrets Manager ==="
SECRET_ARN=$(aws secretsmanager create-secret \
  --region "$REGION" \
  --name "mgn/fsx/ontap-api-certificate" \
  --description "Client certificate for MGN to authenticate with FSx ONTAP REST API" \
  --secret-string "{\"cert\":$(echo "$CERT_CONTENT" | jq -Rs .),\"key\":$(echo "$KEY_CONTENT" | jq -Rs .)}" \
  --tags Key=AWSApplicationMigrationServiceManaged,Value=True \
  --query "ARN" --output text)

save_output "SECRET_ARN" "$SECRET_ARN"

echo ""
echo "=== Done ==="
echo "Secret ARN: $SECRET_ARN"
echo ""
echo "IMPORTANT: The tag 'AWSApplicationMigrationServiceManaged: True' is required."
echo "Without it, MGN cannot access the secret and 'Create staging disks' will fail."
