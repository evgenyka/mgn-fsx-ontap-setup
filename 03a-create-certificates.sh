#!/bin/bash
# Step 3a: Generate certificates for FSx ONTAP authentication
# Reference: https://integ.www.docs.aws.a2z.com/mgn/latest/ug/fsx-ontap.html#fsx-ontap-step3-certificate-auth
set -e
source "$(dirname "$0")/helpers.sh"
load_config

CERT_DIR="$(dirname "$0")/certs"
mkdir -p "$CERT_DIR"

echo "=== Generating CA private key ==="
openssl genrsa -out "$CERT_DIR/ca.key" 4096

echo "=== Creating self-signed CA certificate ==="
openssl req -new -x509 -key "$CERT_DIR/ca.key" -out "$CERT_DIR/ca.crt" -days 3650 \
  -subj "/CN=FSx-ONTAP-Client-CA/O=YourOrg/C=US" \
  -addext basicConstraints=critical,CA:TRUE \
  -addext keyUsage=critical,keyCertSign,cRLSign \
  -addext subjectKeyIdentifier=hash

echo "=== Generating client key ==="
openssl genrsa -out "$CERT_DIR/fsx-mgn-client.key" 2048

echo "=== Creating openssl config ==="
cat > "$CERT_DIR/openssl-client.cnf" << 'EOF'
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
CN = cert_usr
O  = YourOrg
C  = US

[ req_ext ]
keyUsage         = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
subjectKeyIdentifier = hash

[ usr_cert ]
keyUsage         = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
authorityKeyIdentifier = keyid,issuer
subjectKeyIdentifier  = hash
EOF

echo "=== Creating CSR ==="
openssl req -new -key "$CERT_DIR/fsx-mgn-client.key" -out "$CERT_DIR/fsx-mgn-client.csr" \
  -config "$CERT_DIR/openssl-client.cnf"

echo "=== Signing certificate with CA ==="
openssl x509 -req -in "$CERT_DIR/fsx-mgn-client.csr" \
  -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
  -out "$CERT_DIR/fsx-mgn-client.crt" -days 365 \
  -extfile "$CERT_DIR/openssl-client.cnf" -extensions usr_cert

echo "=== Verifying certificate ==="
openssl verify -CAfile "$CERT_DIR/ca.crt" "$CERT_DIR/fsx-mgn-client.crt"

echo ""
echo "=== Done ==="
echo "CA cert:     $CERT_DIR/ca.crt"
echo "Client cert: $CERT_DIR/fsx-mgn-client.crt"
echo "Client key:  $CERT_DIR/fsx-mgn-client.key"
echo ""
echo "Next: Install CA cert on FSx ONTAP (see 03-install-cert-ontap.sh)"
