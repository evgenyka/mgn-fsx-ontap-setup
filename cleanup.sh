#!/bin/bash
# Cleanup: Delete MGN + FSx ONTAP setup resources
# WARNING: This will delete security groups and secrets
set -e
source "$(dirname "$0")/config.env"

echo "=== This will delete MGN + FSx ONTAP setup resources ==="
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

echo "=== Deleting Secrets Manager secret ==="
aws secretsmanager delete-secret \
  --region "$REGION" \
  --secret-id "mgn/fsx/ontap-api-certificate" \
  --force-delete-without-recovery 2>/dev/null && \
  echo "Secret deleted" || echo "Secret not found"

echo "=== Deleting security groups ==="
MGN_SG_ID=$(aws ec2 describe-security-groups \
  --region "$REGION" \
  --filters "Name=group-name,Values=MGN-Instances-SG" "Name=vpc-id,Values=$VPC_ID" \
  --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

FSX_SG_ID=$(aws ec2 describe-security-groups \
  --region "$REGION" \
  --filters "Name=group-name,Values=FSx-ONTAP-SG" "Name=vpc-id,Values=$VPC_ID" \
  --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

if [ "$MGN_SG_ID" != "None" ] && [ -n "$MGN_SG_ID" ]; then
  aws ec2 delete-security-group --region "$REGION" --group-id "$MGN_SG_ID" 2>/dev/null && \
    echo "Deleted MGN-Instances-SG: $MGN_SG_ID" || echo "Cannot delete MGN-Instances-SG (may be in use)"
fi

if [ "$FSX_SG_ID" != "None" ] && [ -n "$FSX_SG_ID" ]; then
  aws ec2 delete-security-group --region "$REGION" --group-id "$FSX_SG_ID" 2>/dev/null && \
    echo "Deleted FSx-ONTAP-SG: $FSX_SG_ID" || echo "Cannot delete FSx-ONTAP-SG (may be in use)"
fi

echo ""
echo "=== Manual cleanup required ==="
echo "1. Remove certificate from FSx ONTAP CLI:"
echo "   security certificate delete -vserver $FSX_SVM_NAME -cert-name $CERT_CA_NAME -type client-ca"
echo "2. Remove login from FSx ONTAP CLI:"
echo "   security login delete -vserver $FSX_SVM_NAME -user-or-group-name $CERT_USER_NAME -application http -authmethod cert"
echo "3. Delete offline FSx ONTAP volumes/LUNs from MGN migrations"
echo "4. Update MGN replication settings to remove FSx configuration"
