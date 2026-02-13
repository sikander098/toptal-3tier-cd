#!/bin/bash
# RDS Backup Script - Creates manual snapshot and cleans up old ones
set -euo pipefail

DATE=$(date +%Y%m%d-%H%M%S)
DB_INSTANCE="toptal-3tier-db"
SNAPSHOT_ID="toptal-backup-${DATE}"
REGION="us-east-1"

echo "=== RDS Backup: ${DATE} ==="

# Create RDS snapshot
echo "Creating RDS snapshot: ${SNAPSHOT_ID}"
aws rds create-db-snapshot \
  --db-instance-identifier ${DB_INSTANCE} \
  --db-snapshot-identifier ${SNAPSHOT_ID} \
  --region ${REGION}

echo "Waiting for snapshot to complete..."
aws rds wait db-snapshot-available \
  --db-snapshot-identifier ${SNAPSHOT_ID} \
  --region ${REGION}

echo "Snapshot ${SNAPSHOT_ID} completed successfully"

# Clean up old snapshots (keep last 7)
echo "Cleaning up old snapshots..."
OLD_SNAPSHOTS=$(aws rds describe-db-snapshots \
  --db-instance-identifier ${DB_INSTANCE} \
  --snapshot-type manual \
  --query 'reverse(sort_by(DBSnapshots,&SnapshotCreateTime))[7:].DBSnapshotIdentifier' \
  --output text \
  --region ${REGION})

for snap in ${OLD_SNAPSHOTS}; do
  echo "Deleting old snapshot: ${snap}"
  aws rds delete-db-snapshot --db-snapshot-identifier ${snap} --region ${REGION} || true
done

echo "=== Backup complete ==="