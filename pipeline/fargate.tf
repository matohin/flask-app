resource "aws_ecs_cluster" "cluster" {
  name = "ecs-cluster"

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

module "ecs-fargate" {
  source = "umotif-public/ecs-fargate/aws"
  version = "~> 6.1.0"

  name_prefix        = "flask-app-fargate"
  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = data.aws_subnet_ids.all.ids

  cluster_id         = aws_ecs_cluster.cluster.id

  task_container_image   = "${module.ecr.repository_url}:latest"
  task_definition_cpu    = 256
  task_definition_memory = 512

  task_container_port             = 80
  task_container_assign_public_ip = true

  target_groups = [
    {
      target_group_name = "flask-app-group"
      container_port    = 80
    }
  ]

  health_check = {
    port = "traffic-port"
    path = "/"
  }

  tags = {
    Environment = "dev"
    Project = "flask-app"
  }

  depends_on = [
    module.alb
  ]
}

resource "aws_security_group_rule" "task_ingress_80" {
  security_group_id        = module.ecs-fargate.service_sg_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  // source_security_group_id = module.alb.security_group_id
  cidr_blocks              = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "task_ingress_443" {
  security_group_id        = module.ecs-fargate.service_sg_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group" "allow_sg_test" {
  name        = "allow_sg_test"
  description = "Allow sg inbound traffic"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "test_sg_ingress" {
  security_group_id        = aws_security_group.allow_sg_test.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3022
  to_port                  = 3022
  source_security_group_id = module.ecs-fargate.service_sg_id
}
