#!/bin/bash
# Step 3b: Install certificate on FSx ONTAP and create login
# Reference: https://integ.www.docs.aws.a2z.com/mgn/latest/ug/fsx-ontap.html#fsx-ontap-step3-certificate-auth
# NOTE: This step requires SSH access to FSx ONTAP management endpoint.
#       Run from a bastion host or EC2 instance in the same VPC.
set -e
source "$(dirname "$0")/helpers.sh"
load_config

FSX_SVM_NAME="FsxId${FSX_FILE_SYSTEM_ID#fs-}"

CERT_DIR="$(dirname "$0")/certs"

echo "=== Instructions ==="
echo ""
echo "SSH to FSx ONTAP management endpoint:"
echo "  ssh fsxadmin@$FSX_MANAGEMENT_IP"
echo "  Password: $FSX_ADMIN_PASSWORD"
echo ""
echo "Then run these ONTAP CLI commands:"
echo ""
echo "1. Install the client CA certificate:"
echo "   security certificate install -type client-ca \\"
echo "     -vserver $FSX_SVM_NAME -cert-name $CERT_CA_NAME"
echo ""
echo "   (Paste contents of $CERT_DIR/ca.crt when prompted)"
echo ""
echo "2. Create the certificate auth user:"
echo "   security login create -vserver $FSX_SVM_NAME \\"
echo "     -user-or-group-name $CERT_USER_NAME -application http \\"
echo "     -authmethod cert -role fsxadmin"
echo ""
echo "3. Verify:"
echo "   security login show -vserver $FSX_SVM_NAME -user-or-group-name $CERT_USER_NAME"
echo "   security certificate show -vserver $FSX_SVM_NAME -type client-ca"
echo ""
echo "4. Test from bastion (after copying cert files there):"
echo "   curl -sSk --cert fsx-mgn-client.crt --key fsx-mgn-client.key \\"
echo "     https://management.$FSX_FILE_SYSTEM_ID.fsx.$REGION.amazonaws.com/api/cluster"
