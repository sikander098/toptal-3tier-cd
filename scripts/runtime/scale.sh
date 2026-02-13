#!/bin/bash
# Scale the application replicas
set -euo pipefail

REPLICAS=${1:-2}
REGION="us-east-1"
CLUSTER="toptal-3tier-eks"
NODEGROUP="toptal-3tier-nodes"

echo "=== Scaling application to ${REPLICAS} replicas ==="

# Scale rollouts
kubectl scale rollout web --replicas=${REPLICAS} -n toptal
kubectl scale rollout api --replicas=${REPLICAS} -n toptal

# If scaling up, ensure enough nodes
if [ ${REPLICAS} -gt 2 ]; then
  DESIRED_NODES=$(( (REPLICAS + 1) / 2 ))
  [ ${DESIRED_NODES} -gt 3 ] && DESIRED_NODES=3
  echo "Scaling node group to ${DESIRED_NODES} nodes..."
  aws eks update-nodegroup-config \
    --cluster-name ${CLUSTER} \
    --nodegroup-name ${NODEGROUP} \
    --scaling-config minSize=2,maxSize=3,desiredSize=${DESIRED_NODES} \
    --region ${REGION}
fi

echo "Waiting for pods..."
sleep 10
kubectl get pods -n toptal
echo "=== Scale complete ==="