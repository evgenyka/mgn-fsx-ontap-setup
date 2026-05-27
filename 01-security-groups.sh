#!/bin/bash
# Step 1: Configure security groups
# Reference: https://integ.www.docs.aws.a2z.com/mgn/latest/ug/fsx-ontap.html#fsx-ontap-step1-security-groups
set -e
source "$(dirname "$0")/helpers.sh"
load_config

echo "=== Creating MGN-Instances-SG ==="
MGN_SG_ID=$(aws ec2 create-security-group \
  --region "$REGION" \
  --group-name MGN-Instances-SG \
  --description "Security group for instances launched by Application Migration Service to allow communication with FSx for ONTAP" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" --output text)
save_output "MGN_SG_ID" "$MGN_SG_ID"

echo "=== Creating FSx-ONTAP-SG ==="
FSX_SG_ID=$(aws ec2 create-security-group \
  --region "$REGION" \
  --group-name FSx-ONTAP-SG \
  --description "Security group for FSx for ONTAP file system to allow inbound access from MGN-launched instances" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" --output text)
save_output "FSX_SG_ID" "$FSX_SG_ID"

echo "=== Adding MGN-Instances-SG inbound rules ==="
# TCP 1500 for data replication from source servers
aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$MGN_SG_ID" \
  --protocol tcp --port 1500 --cidr 0.0.0.0/0

echo "=== Adding FSx-ONTAP-SG inbound rules ==="
# iSCSI from MGN instances
aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$FSX_SG_ID" \
  --protocol tcp --port 3260 --source-group "$MGN_SG_ID"

# SSH from MGN instances (management)
aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$FSX_SG_ID" \
  --protocol tcp --port 22 --source-group "$MGN_SG_ID"

# HTTPS from MGN instances (ONTAP REST API)
aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$FSX_SG_ID" \
  --protocol tcp --port 443 --source-group "$MGN_SG_ID"

# HTTPS from FSx preferred subnet (for PrivateLink)
aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$FSX_SG_ID" \
  --protocol tcp --port 443 --cidr "$FSX_PREFERRED_SUBNET_CIDR"

# HTTPS from FSx standby subnet (for PrivateLink)
aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$FSX_SG_ID" \
  --protocol tcp --port 443 --cidr "$FSX_STANDBY_SUBNET_CIDR"

echo ""
echo "=== Done ==="
echo "MGN-Instances-SG: $MGN_SG_ID"
echo "FSx-ONTAP-SG:     $FSX_SG_ID"
