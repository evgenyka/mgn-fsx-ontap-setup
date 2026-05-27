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
./01-security-groups.sh

# 3. Create FSx for ONTAP file system
./02-create-fsx-ontap.sh

# 4. Create bastion host for FSx management
./03-create-bastion.sh

# 5. Generate certificates
./04-create-certificates.sh

# 6. Install cert on FSx ONTAP (manual step - follow instructions)
./05-install-cert-ontap.sh

# 7. Store certificates in AWS Secrets Manager
./06-store-secrets.sh

# 8. Configure MGN replication settings (console instructions)
./07-configure-replication.sh

# 9. Configure launch template and launch settings (console instructions)
./08-configure-launch-settings.sh

# 10. Enable volume integrity validation (console instructions)
./09-enable-volume-validation.sh
```

## Scripts

| Script | Description | Type |
|--------|-------------|------|
| `config.env` | Configuration variables | Config |
| `01-security-groups.sh` | Create MGN-Instances-SG and FSx-ONTAP-SG | Automated |
| `02-create-fsx-ontap.sh` | Create FSx for ONTAP file system | Automated |
| `03-create-bastion.sh` | Create bastion host for FSx management | Automated |
| `04-create-certificates.sh` | Generate CA and client certificates | Automated |
| `05-install-cert-ontap.sh` | Install cert on FSx ONTAP CLI | Instructions |
| `06-store-secrets.sh` | Store cert/key in Secrets Manager | Automated |
| `07-configure-replication.sh` | Configure MGN replication template | Instructions |
| `08-configure-launch-settings.sh` | Configure launch template and settings | Instructions |
| `09-enable-volume-validation.sh` | Enable post-launch validation | Instructions |
| `cleanup.sh` | Tear down resources | Automated |

## Important Notes

- The `AWSApplicationMigrationServiceManaged: True` tag on the Secrets Manager secret is **required**. Without it, MGN cannot access the secret.
- FSx-ONTAP-SG needs HTTPS (443) from both the preferred and standby subnet CIDRs for MGN internal connectivity.
- Disable automatic backups on FSx during migration.
- Disable Anti-Ransomware Protection (ARP) if enabled.
- Provision 3x the size of planned migration data on FSx.
- Replication settings changes take up to 30 minutes to propagate to existing source servers.
