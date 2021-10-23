resource "aws_ecs_cluster" "cluster" {
  name = "example-ecs-cluster"

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
  task_container_assign_public_ip = false

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