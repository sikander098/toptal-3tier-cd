aws_region  = "us-east-1"
environment = "production"

# EKS
eks_cluster_version     = "1.31"
eks_node_instance_types = ["t3.medium"]
eks_node_desired        = 2
eks_node_min            = 2
eks_node_max            = 3

# RDS
db_instance_class = "db.t3.micro"
db_name           = "toptal3tier"
db_username       = "dbadmin"
# db_password is set via TF_VAR_db_password env var or -var flag