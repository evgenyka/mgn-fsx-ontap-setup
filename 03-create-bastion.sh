#!/bin/bash
# Create a bastion host for FSx ONTAP management access (SSH + HTTPS to management endpoint)
set -e
source "$(dirname "$0")/helpers.sh"
load_config

echo "=== Creating bastion key pair ==="
KEY_NAME="fsx-bastion-${REGION}"
aws ec2 create-key-pair \
  --region "$REGION" \
  --key-name "$KEY_NAME" \
  --key-type rsa \
  --query "KeyMaterial" --output text > "${KEY_NAME}.pem" 2>/dev/null && \
  chmod 400 "${KEY_NAME}.pem" && \
  echo "Key saved to ${KEY_NAME}.pem" || \
  echo "Key pair already exists"
save_output "BASTION_KEY_NAME" "$KEY_NAME"

echo "=== Creating bastion security group ==="
BASTION_SG_ID=$(aws ec2 create-security-group \
  --region "$REGION" \
  --group-name fsx-bastion-sg \
  --description "Bastion host for FSx ONTAP management access" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" --output text)
save_output "BASTION_SG_ID" "$BASTION_SG_ID"

aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$BASTION_SG_ID" \
  --protocol tcp --port 22 --cidr 0.0.0.0/0

echo "=== Adding bastion access to FSx-ONTAP-SG ==="
# SSH from bastion to FSx
aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$FSX_SG_ID" \
  --protocol tcp --port 22 --source-group "$BASTION_SG_ID"

# HTTPS from bastion to FSx (for cert testing)
aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$FSX_SG_ID" \
  --protocol tcp --port 443 --source-group "$BASTION_SG_ID"

echo "=== Launching bastion instance ==="
AMI_ID=$(aws ec2 describe-images \
  --region "$REGION" \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023*-x86_64" "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)

BASTION_ID=$(aws ec2 run-instances \
  --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type t3.small \
  --key-name "$KEY_NAME" \
  --subnet-id "$FSX_PREFERRED_SUBNET_ID" \
  --security-group-ids "$BASTION_SG_ID" \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=fsx-bastion}]' \
  --query "Instances[0].InstanceId" --output text)
save_output "BASTION_INSTANCE_ID" "$BASTION_ID"

echo "Waiting for bastion to start..."
aws ec2 wait instance-running --region "$REGION" --instance-ids "$BASTION_ID"

BASTION_IP=$(aws ec2 describe-instances \
  --region "$REGION" \
  --instance-ids "$BASTION_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
save_output "BASTION_IP" "$BASTION_IP"

echo ""
echo "=== Done ==="
echo "Bastion instance: $BASTION_ID"
echo "Bastion IP: $BASTION_IP"
echo ""
echo "SSH to bastion:"
echo "  ssh -i ${KEY_NAME}.pem ec2-user@$BASTION_IP"
echo ""
echo "From bastion, SSH to FSx ONTAP (after file system is available):"
echo "  ssh fsxadmin@<FSx-management-IP>"
