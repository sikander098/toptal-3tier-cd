#!/bin/bash
# Check the status of all infrastructure components
set -euo pipefail

REGION="us-east-1"
CLUSTER="toptal-3tier-eks"
DB_INSTANCE="toptal-3tier-db"

echo "============================================"
echo "  Toptal 3-Tier Infrastructure Status"
echo "============================================"
echo ""

# EKS Cluster
echo "--- EKS Cluster ---"
aws eks describe-cluster --name ${CLUSTER} --query 'cluster.status' --output text --region ${REGION}
echo ""

# Nodes
echo "--- Kubernetes Nodes ---"
kubectl get nodes 2>/dev/null || echo "Cannot reach cluster"
echo ""

# RDS
echo "--- RDS Database ---"
aws rds describe-db-instances --db-instance-identifier ${DB_INSTANCE} \
  --query 'DBInstances[0].{Status:DBInstanceStatus,Endpoint:Endpoint.Address,Storage:AllocatedStorage}' \
  --output table --region ${REGION} 2>/dev/null || echo "RDS not found"
echo ""

# Application pods
echo "--- Application Pods ---"
kubectl get pods -n toptal 2>/dev/null || echo "Cannot reach cluster"
echo ""

# Rollouts
echo "--- Argo Rollouts ---"
kubectl get rollouts -n toptal 2>/dev/null || echo "Cannot reach cluster"
echo ""

# Ingress
echo "--- Ingress / Load Balancer ---"
kubectl get ingress -n toptal 2>/dev/null || echo "Cannot reach cluster"
echo ""

# Monitoring
echo "--- Monitoring ---"
kubectl get pods -n monitoring 2>/dev/null || echo "Monitoring not deployed"
echo ""

# Logging
echo "--- Logging ---"
kubectl get pods -n logging 2>/dev/null || echo "Logging not deployed"
echo ""

echo "============================================"