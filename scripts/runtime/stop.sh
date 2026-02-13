#!/bin/bash
# Stop the infrastructure to save costs
set -euo pipefail

REGION="us-east-1"
CLUSTER="toptal-3tier-eks"
NODEGROUP="toptal-3tier-nodes"
DB_INSTANCE="toptal-3tier-db"

echo "=== Stopping Toptal 3-Tier Infrastructure ==="

# 1. Scale down app
echo "1. Scaling down application..."
kubectl scale rollout web --replicas=0 -n toptal 2>/dev/null || true
kubectl scale rollout api --replicas=0 -n toptal 2>/dev/null || true

# 2. Scale down EKS nodes
echo "2. Scaling down EKS node group..."
aws eks update-nodegroup-config \
  --cluster-name ${CLUSTER} \
  --nodegroup-name ${NODEGROUP} \
  --scaling-config minSize=0,maxSize=3,desiredSize=0 \
  --region ${REGION}
echo "   Node group scaling to 0"

# 3. Stop RDS
echo "3. Stopping RDS instance..."
aws rds stop-db-instance --db-instance-identifier ${DB_INSTANCE} --region ${REGION} 2>/dev/null || true
echo "   RDS stopping (auto-restarts after 7 days if not started)"

echo ""
echo "=== Infrastructure stopped (cost saving mode) ==="
echo "Run ./start.sh to restart"