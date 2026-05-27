#!/bin/bash
# Step 10: Increase FSx ONTAP throughput capacity
# Use this after initial setup to speed up replication/migration
# NOTE: Throughput capacity is a billable resource - higher = more cost
set -e
source "$(dirname "$0")/helpers.sh"
load_config

NEW_THROUGHPUT=${1:-256}

echo "=== Increasing FSx throughput capacity ==="
echo "File System: $FSX_FILE_SYSTEM_ID"
echo "New throughput: ${NEW_THROUGHPUT} MBps"
echo ""
echo "Available values: 128, 256, 512, 1024, 2048, 4096 MBps"
echo "NOTE: This is a billable change. Higher throughput = higher cost."
echo ""

aws fsx update-file-system \
  --region "$REGION" \
  --file-system-id "$FSX_FILE_SYSTEM_ID" \
  --ontap-configuration "{\"ThroughputCapacity\": $NEW_THROUGHPUT}" \
  --query "FileSystem.Lifecycle" --output text

echo ""
echo "=== Throughput update initiated ==="
echo "The file system will briefly enter 'UPDATING' state."
echo "Monitor: aws fsx describe-file-systems --region $REGION --file-system-ids $FSX_FILE_SYSTEM_ID --query 'FileSystems[0].Lifecycle'"
echo ""
echo "No downtime — the update is non-disruptive."
