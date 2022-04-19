resource "aws_ecs_task_definition" "main" {
  family                   = data.consul_keys.input.var.project-name
  cpu                      = data.consul_keys.input.var.cpu
  memory                   = data.consul_keys.input.var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_iam_role.arn
  task_role_arn            = aws_iam_role.ecs_iam_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "name": "CONTAINER-${data.consul_keys.input.var.service_name}-${var.ENVIRONMENT}",
    "image": "${var.container_definition_image}",
    "essential": true,
    "environment": [
      {
        "name": "ENVIRONMENT",
        "value": "${var.ENVIRONMENT}"
      },
      {
        "name": "CONSUL_HTTP_ADDR",
        "value": "${var.consul_address}"
      },
      {
        "name": "CONSUL_HTTP_TOKEN",
        "value": "${var.consul_token}"
      }
    ],
    "portMappings":[
      {
        "protocol": "tcp",
        "containerPort": ${data.consul_keys.input.var.container_port},
        "hostPort": ${data.consul_keys.input.var.container_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${data.consul_keys.input.var.service_name}",
        "awslogs-region": "${data.consul_keys.input.var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
  tags = {
    Proyecto    = data.consul_keys.input.var.project-name
    CECO        = data.consul_keys.input.var.ceco
    Country     = data.consul_keys.input.var.country
    Environment = var.ENVIRONMENT
    Owner       = data.consul_keys.input.var.owner
    Region      = data.consul_keys.input.var.region
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = data.consul_keys.input.var.service_name

  tags = {
    Proyecto    = data.consul_keys.input.var.project-name
    CECO        = data.consul_keys.input.var.ceco
    Country     = data.consul_keys.input.var.country
    Environment = var.ENVIRONMENT
    Owner       = data.consul_keys.input.var.owner
    Region      = data.consul_keys.input.var.region
  }
}

resource "aws_iam_role" "ecs_iam_role" {
  name               = "${data.consul_keys.input.var.service_name}-${var.ENVIRONMENT}-IAM-Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com", "dynamodb.amazonaws.com"]
    },
    "Action": "sts:AssumeRole"
  }
  ]
}
EOF
}



resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "main" {
  name            = "SERVICE-${data.consul_keys.input.var.service_name}-${var.ENVIRONMENT}"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = data.consul_keys.input.var.desired-count
  cluster         = data.consul_keys.output.var.aws_ecs_cluster-id
  launch_type     = "FARGATE"

  tags = {
    Proyecto    = data.consul_keys.input.var.project-name
    CECO        = data.consul_keys.input.var.ceco
    Country     = data.consul_keys.input.var.country
    Environment = var.ENVIRONMENT
    Owner       = data.consul_keys.input.var.owner
    Region      = data.consul_keys.input.var.region
  }

  network_configuration {
    subnets          = data.aws_subnet_ids.private.ids
    security_groups  = [aws_security_group.app_security_group.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = "CONTAINER-${data.consul_keys.input.var.service_name}-${var.ENVIRONMENT}"
    container_port   = data.consul_keys.input.var.container_port
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }

}

resource "aws_security_group" "app_security_group" {
  name        = "${data.consul_keys.input.var.service_name}-SG"
  description = "Security group for app to communicate in and out"
  vpc_id      = data.consul_keys.input.var.vpc-id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [data.consul_keys.output.var.aws_security_group-id]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Proyecto    = data.consul_keys.input.var.project-name
    CECO        = data.consul_keys.input.var.ceco
    Country     = data.consul_keys.input.var.country
    Environment = var.ENVIRONMENT
    Owner       = data.consul_keys.input.var.owner
    Region      = data.consul_keys.input.var.region
  }
}

resource "aws_alb_target_group" "ecs_app_target_group" {
  name        = "TG-${data.consul_keys.input.var.service_name}1-${var.ENVIRONMENT}"
  port        = data.consul_keys.input.var.container_port
  protocol    = "HTTP"
  vpc_id      = data.consul_keys.input.var.vpc-id
  target_type = "ip"

  health_check {
    path                = data.consul_keys.input.var.url_value
    protocol            = "HTTP"
    matcher             = "200"
    interval            = "60"
    timeout             = "30"
    unhealthy_threshold = "3"
    healthy_threshold   = "3"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Proyecto    = data.consul_keys.input.var.project-name
    CECO        = data.consul_keys.input.var.ceco
    Country     = data.consul_keys.input.var.country
    Environment = var.ENVIRONMENT
    Owner       = data.consul_keys.input.var.owner
    Region      = data.consul_keys.input.var.region
  }
}

resource "aws_alb_listener_rule" "ecs_alb_listener_rule" {
  listener_arn = data.consul_keys.output.var.aws_alb_listener-id
  priority     = 89
  tags = {
    Proyecto    = data.consul_keys.input.var.project-name
    CECO        = data.consul_keys.input.var.ceco
    Country     = data.consul_keys.input.var.country
    Environment = var.ENVIRONMENT
    Owner       = data.consul_keys.input.var.owner
    Region      = data.consul_keys.input.var.region
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }

  condition {
    path_pattern {
      values = [data.consul_keys.input.var.url_value, "${data.consul_keys.input.var.url_value}/*"]
    }
  }
}

resource "aws_iam_policy" "dynamodb" {
  name        = "${data.consul_keys.input.var.service_name}-task-policy-dynamodb"
  description = "Policy that allows access to DynamoDB"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_iam_role.name
  policy_arn = aws_iam_policy.dynamodb.arn
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "document-${data.consul_keys.input.var.db_environment}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "uuid"
  range_key      = "category"

  attribute {
    name = "uuid"
    type = "S"
  }

  attribute {
    name = "category"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table"
    Environment = var.ENVIRONMENT
  }
}