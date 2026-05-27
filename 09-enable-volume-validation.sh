#!/bin/bash
# Step 7: Enable volume integrity validation (recommended)
# Reference: https://integ.www.docs.aws.a2z.com/mgn/latest/ug/fsx-ontap.html#fsx-ontap-step7-post-launch-validation
set -e
source "$(dirname "$0")/helpers.sh"
load_config

echo "=== Enable Volume Integrity Validation ==="
echo ""
echo "This post-launch action automatically verifies iSCSI connectivity"
echo "and multipath mount configuration after each test or cutover launch."
echo ""
echo "To enable:"
echo ""
echo "1. Navigate to: MGN Console > Source servers > [server] > Post-launch settings"
echo "2. Enable the 'Volume integrity validation' action"
echo ""
echo "For more information, see:"
echo "  https://docs.aws.amazon.com/mgn/latest/ug/predefined-post-launch-actions.html#predefined-volume-integrity-validation"
echo ""
echo "NOTE: This action validates that all expected iSCSI volumes are connected,"
echo "mounted, and accessible through multipath."
