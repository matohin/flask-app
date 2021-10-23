module "alb" {
  source  = "umotif-public/alb/aws"
  version = "~> 2.0"

  name_prefix        = "flask-app-alb"
  load_balancer_type = "application"
  internal           = false
  vpc_id             = data.aws_vpc.default.id
  subnets            = data.aws_subnet_ids.all.ids
}

resource "aws_lb_listener" "alb_80" {
  load_balancer_arn = module.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.ecs-fargate.target_group_arn[0]
  }
}
