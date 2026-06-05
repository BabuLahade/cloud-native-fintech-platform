### IAM role for eks control

resource "aws_iam_role" "cluster" {
    name = "${var.project}-${var.environment}-eks-cluster-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [ 
            {
                Effect ="Allow"
                Principal = {Service = "eks.amazonaws.com"}
                Action  = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role" "nodes" {
    name = "${var.project}-${var.environment}-eks-nodes-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [ 
            {
                Effect ="Allow"
                Principal = {Service = "ec2.amazonaws.com"}
                Action  = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "nodes_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
  
}

resource "aws_iam_role_policy_attachment" "nodes_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_ecr_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role      = aws_iam_role.nodes.name
}


############ security groups 

resource "aws_security_group" "cluster" {
  name = "${var.project}-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-eks-cluster-sg"
  }
}


########## EKS Cluster 
resource "aws_eks_cluster" "main" {
    name = "${var.project}-${var.environment}"
    version = var.cluster_version
    role_arn = aws_iam_role.cluster.arn

    vpc_config {
        subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)
        security_group_ids = [aws_security_group.cluster.id]
        endpoint_private_access = true
        endpoint_public_access = true
    }

    enabled_cluster_log_types = ["api", "audit", "authenticator"]

    depends_on = [ 
        aws_iam_role_policy_attachment.cluster_policy
     ]

    tags = {
    Name = "${var.project}-${var.environment}"
  }
}

#####OIDC provider for EKS cluster
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  
  tags = {
    Name = "${var.project}-${var.environment}-oidc"
  }
}

########### managed node group 
resource "aws_eks_node_group" "main" {
  cluster_name = aws_eks_cluster.main.name
  node_group_name = "${var.project}-${var.environment}-node-group"
  node_role_arn = aws_iam_role.nodes.arn
  subnet_ids = var.private_subnet_ids

  instance_types = [var.node_instance_type]

  scaling_config {
    min_size = var.node_min_size
    max_size = var.node_max_size
    desired_size = var.node_desired_size

  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [ 
    aws_iam_role_policy_attachment.nodes_ecr_policy ,
    aws_iam_role_policy_attachment.nodes_worker_policy ,
    aws_iam_role_policy_attachment.nodes_cni_policy
   ]

   tags = {
    Name = "${var.project}-${var.environment}-nodes"
    # Required for Karpenter discovery in Phase 5
    "karpenter.sh/discovery" = "${var.project}-${var.environment}"
  }

}