resource "aws_lb" "gwlb" {
  name               = "Security-VPC-GWLB"
  load_balancer_type = "gateway"
  subnet_mapping {
    subnet_id = var.trust_subnet_az1
  }
  subnet_mapping {
    subnet_id = var.trust_subnet_az2
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]
  
  depends_on = [aws_lb.gwlb]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.gwlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# One target group is possible for one gwlb, or else it fails with "You cannot specify multiple target groups in a single action with a load balancer of type 'gateway'".
resource "aws_lb_target_group" "this" {
  name                 = "Security-VPC-Target-Group"
  vpc_id               = var.vpc_id
  target_type          = "ip" #Change this to IP
  protocol             = "GENEVE"
  port                 = "6081"
  deregistration_delay = var.deregistration_delay
  # Tags were accepted on old aws providers starting from v3.18, but since v3.49 they fail with
  # "You cannot specify tags on creation of a GENEVE target group".
  # https://github.com/hashicorp/terraform-provider-aws/issues/20144
  #
  # tags = merge(var.global_tags, { Name = var.name }, var.lb_target_group_tags)
  # tags = var.lb_target_group_tags

  health_check {
    enabled             = var.health_check_enabled
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

# Attach one or more Targets (EC2 Instances).
resource "aws_lb_target_group_attachment" "this" {
  count = 2
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = count.index == 0 ? var.PAN_instance_Ip1 : var.PAN_instance_Ip2 #Change this to IP to send the traffic to LAN Interface
}