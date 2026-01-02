##############################################
# Allows Bastion host to connect to MongoDB via SSH (port 22) for administration.
##############################################

resource "aws_security_group_rule" "mongodb_bastion" {
  type                     = "ingress"
  security_group_id        = local.mongodb_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}




##############################################
# Allows Bastion host to connect to Redis via SSH (port 22) for maintenance.
##############################################


resource "aws_security_group_rule" "redis_bastion" {
  type                     = "ingress"
  security_group_id        = local.redis_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}



##############################################
# Allows Bastion host to connect to MySQL via SSH (port 22) for troubleshooting.
##############################################

resource "aws_security_group_rule" "mysql_bastion" {
  type                     = "ingress"
  security_group_id        = local.mysql_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}



##############################################
# Allows Bastion host to connect to RabbitMQ via SSH (port 22) for management.
##############################################

resource "aws_security_group_rule" "rabbitmq_bastion" {
  type                     = "ingress"
  security_group_id        = local.rabbitmq_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}


resource "aws_security_group_rule" "ingress_alb_public" {
  type              = "ingress"
  security_group_id = local.ingress_alb_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
}

##############################################
##### Bastion SG Rules #####
# Allows engineers to SSH into Bastion from any IP (for access to private instances).
##############################################

resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress"
  security_group_id = local.bastion_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
}

resource "aws_security_group_rule" "open_vpn_public" {
  type              = "ingress"
  security_group_id = local.open_vpn_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
}

resource "aws_security_group_rule" "open_vpn_943" {
  type              = "ingress"
  security_group_id = local.open_vpn_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 943
  protocol          = "tcp"
  to_port           = 943
}

resource "aws_security_group_rule" "open_vpn_443" {
  type              = "ingress"
  security_group_id = local.open_vpn_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
}

resource "aws_security_group_rule" "open_vpn_1194" {
  type              = "ingress"
  security_group_id = local.open_vpn_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 1194
  protocol          = "tcp"
  to_port           = 1194
}



resource "aws_security_group_rule" "components_vpn" {
  for_each                 = local.vpn_ingress_rules
  type                     = "ingress"
  security_group_id        = each.value.sg_id
  source_security_group_id = local.open_vpn_sg_id
  from_port                = each.value.port
  protocol                 = "tcp"
  to_port                  = each.value.port
}





resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type                     = "ingress"
  security_group_id        = local.eks_control_plane_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 443
  protocol                 = "tcp"
  to_port                  = 443
}

resource "aws_security_group_rule" "eks_node_bastion" {
  type                     = "ingress"
  security_group_id        = local.eks_node_sg_id
  source_security_group_id = local.bastion_sg_id
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
}

# EKS nodes can accept all kind of traffic from EKS control plane
resource "aws_security_group_rule" "eks_node_eks_control_plane" {
  type                     = "ingress"
  security_group_id        = local.eks_node_sg_id
  source_security_group_id = local.eks_control_plane_sg_id
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 0
}

resource "aws_security_group_rule" "eks_control_plane_eks_node" {
  type                     = "ingress"
  security_group_id        = local.eks_control_plane_sg_id
  source_security_group_id = local.eks_node_sg_id
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 0
}

resource "aws_security_group_rule" "eks_control_plane_default" {
  type                     = "ingress"
  security_group_id        = local.eks_control_plane_sg_id
  source_security_group_id = local.default_sg_id
  from_port                = 443
  protocol                 = "tcp"
  to_port                  = 443
}

resource "aws_security_group_rule" "eks_control_plane_default_all" {
  type                     = "ingress"
  security_group_id        = local.eks_control_plane_sg_id
  source_security_group_id = local.default_sg_id
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 0
}

resource "aws_security_group_rule" "eks_control_plane_default_ssh" {
  type              = "ingress"
  security_group_id = local.eks_control_plane_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "-1"
  to_port           = 22
}


# Mandatory for pod to pod communication. because pods can be in any node in VPC CIDR
resource "aws_security_group_rule" "eks_node_vpc" {
  type              = "ingress"
  security_group_id = local.eks_node_sg_id
  cidr_blocks       = ["10.0.0.0/16"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
}
