#!/bin/bash
# Step 2: Create FSx for ONTAP file system
# Reference: https://integ.www.docs.aws.a2z.com/mgn/latest/ug/fsx-ontap.html#fsx-ontap-step2-create-filesystem
set -e
source "$(dirname "$0")/helpers.sh"
load_config

echo "=== Creating FSx for ONTAP file system ==="

FSX_FILE_SYSTEM_ID=$(aws fsx create-file-system \
  --region "$REGION" \
  --file-system-type ONTAP \
  --storage-capacity "$FSX_STORAGE_CAPACITY" \
  --storage-type SSD \
  --subnet-ids "$TARGET_SUBNET_ID" "$STANDBY_SUBNET_ID" \
  --security-group-ids "$FSX_SG_ID" \
  --ontap-configuration '{
    "DeploymentType": "MULTI_AZ_1",
    "ThroughputCapacity": '"$FSX_THROUGHPUT_CAPACITY"',
    "PreferredSubnetId": "'"$TARGET_SUBNET_ID"'",
    "EndpointIpAddressRange": "'"$FSX_ENDPOINT_IP_RANGE"'",
    "FsxAdminPassword": "'"$FSX_ADMIN_PASSWORD"'",
    "AutomaticBackupRetentionDays": 0
  }' \
  --query "FileSystem.FileSystemId" --output text)

save_output "FSX_FILE_SYSTEM_ID" "$FSX_FILE_SYSTEM_ID"

echo ""
echo "=== FSx file system creating ==="
echo "File System ID: $FSX_FILE_SYSTEM_ID"
echo ""
echo "Wait ~30-45 minutes for the file system to reach 'Available' status."
echo "Monitor:"
echo "  aws fsx describe-file-systems --region $REGION --file-system-ids $FSX_FILE_SYSTEM_ID --query 'FileSystems[0].Lifecycle'"
echo ""
echo "After available, run this to get management IP and SVM name:"
echo "  aws fsx describe-file-systems --region $REGION --file-system-ids $FSX_FILE_SYSTEM_ID \\"
echo "    --query 'FileSystems[0].OntapConfiguration.Endpoints.Management.IpAddresses[0]' --output text"
echo ""
echo "Then update outputs.env with FSX_MANAGEMENT_IP and FSX_SVM_NAME (FsxId<id>)"
echo ""
echo "IMPORTANT:"
echo "- Automatic backups are disabled (can interfere with replication)"
echo "- Multi-AZ deployment with endpoint IP range 192.168.1.0/24"
echo "- Provision 3x the size of planned migration data"
echo "- Disable Anti-Ransomware Protection (ARP) if enabled"
