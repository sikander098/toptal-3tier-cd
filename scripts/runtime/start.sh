#!/bin/bash
# Start the infrastructure and application
set -euo pipefail

REGION="us-east-1"
CLUSTER="toptal-3tier-eks"
NODEGROUP="toptal-3tier-nodes"
DB_INSTANCE="toptal-3tier-db"

echo "=== Starting Toptal 3-Tier Infrastructure ==="

# 1. Start RDS if stopped
echo "1. Starting RDS instance..."
DB_STATUS=$(aws rds describe-db-instances --db-instance-identifier ${DB_INSTANCE} --query 'DBInstances[0].DBInstanceStatus' --output text --region ${REGION} 2>/dev/null || echo "not-found")
if [ "${DB_STATUS}" == "stopped" ]; then
  aws rds start-db-instance --db-instance-identifier ${DB_INSTANCE} --region ${REGION}
  echo "   RDS starting... (takes ~5 minutes)"
  aws rds wait db-instance-available --db-instance-identifier ${DB_INSTANCE} --region ${REGION}
  echo "   RDS is available"
else
  echo "   RDS status: ${DB_STATUS} (already running)"
fi

# 2. Scale EKS node group
echo "2. Scaling EKS node group..."
aws eks update-nodegroup-config \
  --cluster-name ${CLUSTER} \
  --nodegroup-name ${NODEGROUP} \
  --scaling-config minSize=2,maxSize=3,desiredSize=2 \
  --region ${REGION}
echo "   Node group scaled to 2 nodes"

# 3. Configure kubectl
echo "3. Configuring kubectl..."
aws eks update-kubeconfig --name ${CLUSTER} --region ${REGION}

# 4. Wait for nodes
echo "4. Waiting for nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# 5. Scale app deployments
echo "5. Scaling application..."
kubectl scale rollout web --replicas=2 -n toptal 2>/dev/null || true
kubectl scale rollout api --replicas=2 -n toptal 2>/dev/null || true

# 6. Verify
echo "6. Verification:"
kubectl get pods -n toptal
kubectl get ingress -n toptal

echo ""
echo "=== Infrastructure started successfully ==="
echo "App URL: http://$(kubectl get ingress toptal-ingress -n toptal -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"