
## Backend API ALB security group
resource "aws_security_group" "backend_api_alb" {
  name        = "backend-api-alb"
  description = "Allow HTTP(S) inbound traffic to backend API ALB only from the frontend subnet"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks      = [data.aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [data.aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [data.aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "backend_api_alb"
  }
}

resource "aws_lb" "backend_api_alb" {
  name               = "backend-api-alb"
  internal           = false
  load_balancer_type = "application"
  vpc_id             = data.aws_vpc.main.id
  subnets            = [data.aws_subnet.public-1.id, data.aws_subnet.public-2.id]
  security_groups    = [aws_security_group.backend_api_alb.id]
  enable_deletion_protection = false
}
 
resource "aws_alb_target_group" "backend_api_alb" {
  name        = "backend-api-alb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.backend_api_alb.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
   type = "redirect"
 
   redirect {
     port        = 443
     protocol    = "HTTPS"
     status_code = "HTTP_301"
   }
  }
}
 
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.backend_api_alb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_tls_cert_arn #TODO: provide a valid certificate ARN
 
  default_action {
    target_group_arn = aws_alb_target_group.backend_api_alb.id
    type             = "forward"
  }
}
