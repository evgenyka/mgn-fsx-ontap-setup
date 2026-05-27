#!/bin/bash
# Step 6: Configure launch template and launch settings
# Reference: https://integ.www.docs.aws.a2z.com/mgn/latest/ug/fsx-ontap.html#fsx-ontap-step6-launch-settings
set -e
source "$(dirname "$0")/helpers.sh"
load_config

echo "=== Configure Launch Template and Launch Settings ==="
echo ""
echo "For each source server in the MGN Console:"
echo ""
echo "1. Navigate to: Source servers > [server] > Launch settings"
echo "2. Modify the EC2 Launch Template to include:"
echo ""
echo "   Subnet:         $TARGET_SUBNET_ID (must communicate with FSx for ONTAP)"
echo "   Security group: $MGN_SG_ID (MGN-Instances-SG - allows iSCSI port 3260)"
echo ""
echo "3. Ensure target instances have network access to OS package repositories."
echo "   MGN automatically installs iSCSI and multipath packages:"
echo ""
echo "   | Package Manager          | Packages Installed                          |"
echo "   |--------------------------|---------------------------------------------|"
echo "   | dnf (Fedora/RHEL 8+)     | iscsi-initiator-utils, device-mapper-multipath |"
echo "   | yum (RHEL 6/7, CentOS)   | iscsi-initiator-utils, device-mapper-multipath |"
echo "   | apt-get (Debian/Ubuntu)   | open-iscsi, multipath-tools                 |"
echo "   | zypper (SLES/openSUSE)    | open-iscsi, multipath-tools                 |"
echo ""
echo "IMPORTANT:"
echo "- If security group was not added to replication template before servers connected,"
echo "  each server's per-server launch template must be updated individually (no bulk update)."
echo "- SLES instances: pre-install open-iscsi and multipath-tools on source before migration"
echo "  (instance-bound repository credentials won't work after migration)."
