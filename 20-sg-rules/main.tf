##############################################
# Allows Bastion host to connect to MongoDB via SSH (port 22)
##############################################
resource "aws_security_group_rule" "mongodb_bastion" {
  type                     = "ingress"
  security_group_id        = local.mongodb_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}



##############################################
# Allows Bastion host to connect to Redis via SSH (port 22)
##############################################
resource "aws_security_group_rule" "redis_bastion" {
  type                     = "ingress"
  security_group_id        = local.redis_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}



##############################################
# Allows Bastion host to connect to MySQL via SSH (port 22)
##############################################
resource "aws_security_group_rule" "mysql_bastion" {
  type                     = "ingress"
  security_group_id        = local.mysql_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}



##############################################
# Allows Bastion host to connect to RabbitMQ via SSH (port 22)
##############################################
resource "aws_security_group_rule" "rabbitmq_bastion" {
  type                     = "ingress"
  security_group_id        = local.rabbitmq_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}


##############################################
# Public ALB HTTPS ingress
##############################################
resource "aws_security_group_rule" "ingress_alb_public" {
  type              = "ingress"
  security_group_id = local.ingress_alb_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

##############################################
# Bastion SSH access
##############################################
resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress"
  security_group_id = local.bastion_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

##############################################
# OpenVPN ingress
##############################################
resource "aws_security_group_rule" "open_vpn_public_ssh" {
  type              = "ingress"
  security_group_id = local.open_vpn_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "open_vpn_943" {
  type              = "ingress"
  security_group_id = local.open_vpn_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
}

resource "aws_security_group_rule" "open_vpn_443" {
  type              = "ingress"
  security_group_id = local.open_vpn_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

resource "aws_security_group_rule" "open_vpn_1194" {
  type              = "ingress"
  security_group_id = local.open_vpn_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
}



##############################################
# VPN access to internal components
##############################################
resource "aws_security_group_rule" "components_vpn" {
  for_each                 = local.vpn_ingress_rules
  type                     = "ingress"
  security_group_id        = each.value.sg_id
  source_security_group_id = local.open_vpn_sg_id
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
}



##############################################
# EKS Bastion access
##############################################
resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type                     = "ingress"
  security_group_id        = local.eks_control_plane_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "eks_node_bastion" {
  type                     = "ingress"
  security_group_id        = local.eks_node_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

##############################################
# EKS control plane <-> node communication
##############################################
resource "aws_security_group_rule" "eks_node_eks_control_plane" {
  type                     = "ingress"
  security_group_id        = local.eks_node_sg_id
  source_security_group_id = local.eks_control_plane_sg_id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}



# Control plane allows traffic from EKS nodes 
resource "aws_security_group_rule" "eks_control_plane_eks_node" {
  type                     = "ingress"
  security_group_id        = local.eks_control_plane_sg_id
  source_security_group_id = local.eks_node_sg_id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}


##############################################
# Pod-to-pod communication inside cluster VPC
##############################################
resource "aws_security_group_rule" "eks_node_vpc" {
  type              = "ingress"
  security_group_id = local.eks_node_sg_id
  cidr_blocks       = ["10.1.0.0/16"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}



# ##############################################
# # Github-runner  access to EKS  control plane 
# ##############################################

resource "aws_security_group_rule" "github_runner_eks_control_plane" {
  type              = "ingress"
  security_group_id = local.eks_control_plane_sg_id

  cidr_blocks = ["172.31.0.0/16"] # Github-runner

  from_port = 443
  to_port   = 443
  protocol  = "tcp"
}

# ##############################################
# # Github-runner access to EKS nodes [EC2 instances]  
# ##############################################
resource "aws_security_group_rule" "eks_node_github_runner" {
  type              = "ingress"
  security_group_id = local.eks_node_sg_id
  cidr_blocks       = ["172.31.0.0/16"] # Github-runner 
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

# ##############################################
# # Jenkins VPC access to EKS (FIXED CIDR)
# ##############################################
# resource "aws_security_group_rule" "eks_control_plane_jenkins" {
#   type              = "ingress"
#   security_group_id = local.eks_control_plane_sg_id
#   cidr_blocks       = ["172.31.0.0/16"] # ✅ Jenkins VPC
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
# }


/* # Nodes allow traffic from Jenkins VPC
resource "aws_security_group_rule" "eks_node_jenkins" {
  type              = "ingress"
  security_group_id = local.eks_node_sg_id
  cidr_blocks       = ["172.31.0.0/16"] # ✅ Jenkins VPC
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
} */



