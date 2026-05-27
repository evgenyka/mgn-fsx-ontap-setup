#!/bin/bash
# Step 5: Configure Application Migration Service replication settings
# Reference: https://integ.www.docs.aws.a2z.com/mgn/latest/ug/fsx-ontap.html#fsx-ontap-step5-mgn-replication
set -e
source "$(dirname "$0")/helpers.sh"
load_config

echo "=== Configure MGN Replication Settings ==="
echo ""
echo "Go to the MGN Console and configure the replication template:"
echo ""
echo "1. Navigate to: Application Migration Service > Settings > Replication template"
echo "2. Choose 'Edit'"
echo "3. Set the following:"
echo ""
echo "   Target subnet:          $FSX_PREFERRED_SUBNET_ID"
echo "   Storage type:           AWS FSx for ONTAP"
echo "   SVM ID:                 (select from list)"
echo "   FSx Storage Secret ARN: $SECRET_ARN"
echo "   Security group:         $MGN_SG_ID (MGN-Instances-SG)"
echo ""
echo "4. Choose 'Save changes'"
echo ""
echo "IMPORTANT:"
echo "- Changing storage provider for a replicating server restarts replication from scratch"
echo "- FSx for ONTAP is supported with agent-based replication only"
echo "- Changes take up to 30 minutes to propagate to existing source servers"
echo "- New source servers pick up changes immediately"
