# MGN + FSx for ONTAP Setup

Automated setup scripts for configuring FSx for ONTAP as the target storage type for AWS Application Migration Service (MGN).

Based on: https://integ.www.docs.aws.a2z.com/mgn/latest/ug/fsx-ontap.html

## Prerequisites

- AWS CLI configured with appropriate credentials
- `openssl` installed (for certificate generation)
- `jq` installed (for JSON processing)
- An AWS account with MGN initialized
- Agent-based replication configured

## Steps

```bash
# 1. Edit configuration
vim config.env

# 2. Configure security groups
./01-configure-security-groups.sh

# 3. Create FSx for ONTAP file system
./02-create-fsx-ontap.sh

# 4. Configure certificate-based authentication
./03a-create-certificates.sh
./03b-install-cert-ontap.sh   # Manual step - follow instructions

# 5. Store certificates in AWS Secrets Manager
./04-store-certificates-secrets-manager.sh

# 6. Configure MGN replication settings
./05-configure-replication-settings.sh   # Console instructions

# 7. Configure launch template and launch settings
./06-configure-launch-settings.sh   # Console instructions

# 8. Enable volume integrity validation
./07-enable-volume-integrity-validation.sh   # Console instructions
```

## Scripts

| Script | Description | Type |
|--------|-------------|------|
| `config.env` | Configuration variables | Config |
| `01-configure-security-groups.sh` | Create MGN-Instances-SG and FSx-ONTAP-SG | Automated |
| `02-create-fsx-ontap.sh` | Create FSx for ONTAP file system | Automated |
| `02b-create-bastion.sh` | Create bastion host for FSx management | Automated |
| `03a-create-certificates.sh` | Generate CA and client certificates | Automated |
| `03b-install-cert-ontap.sh` | Install cert on FSx ONTAP CLI | Instructions |
| `04-store-certificates-secrets-manager.sh` | Store cert/key in Secrets Manager | Automated |
| `05-configure-replication-settings.sh` | Configure MGN replication template | Instructions |
| `06-configure-launch-settings.sh` | Configure launch template and settings | Instructions |
| `07-enable-volume-integrity-validation.sh` | Enable post-launch validation | Instructions |
| `cleanup.sh` | Tear down resources | Automated |

## Important Notes

- The `AWSApplicationMigrationServiceManaged: True` tag on the Secrets Manager secret is **required**. Without it, MGN cannot access the secret.
- FSx-ONTAP-SG needs HTTPS (443) from both the preferred and standby subnet CIDRs for MGN internal connectivity.
- Disable automatic backups on FSx during migration.
- Disable Anti-Ransomware Protection (ARP) if enabled.
- Provision 3x the size of planned migration data on FSx.
- Replication settings changes take up to 30 minutes to propagate to existing source servers.
