data "consul_keys" "input" {
  key {
    name = "container_port"
    path = "${var.consul_project_path}/input/container_port"
  }
  key {
    name = "desired-count"
    path = "${var.consul_infra_path}/input/desired-count"
  }
  key {
    name = "ecs_service_name"
    path = "${var.consul_infra_path}/input/ecs_service_name"
  }
  key {
    name = "memory"
    path = "${var.consul_infra_path}/input/memory"
  }
  key {
    name = "region"
    path = "${var.consul_infra_path}/input/region"
  }
  key {
    name = "url_value"
    path = "${var.consul_project_path}/input/url_value"
  }
  key {
    name = "cpu"
    path = "${var.consul_infra_path}/input/cpu"
  }
  key {
    name = "vpc-id"
    path = "${var.consul_infra_path}/input/vpc-id"
  }
  key {
    name = "private-subnet-id"
    path = "${var.consul_infra_path}/input/private-subnet-id"
  }
  key {
    name = "public-subnet-id"
    path = "${var.consul_infra_path}/input/public-subnet-id"
  }
  key {
    name = "internet-cidr-block"
    path = "${var.consul_infra_path}/input/internet-cidr-block"
  }
  key {
    name = "cluster-name"
    path = "${var.consul_infra_path}/input/cluster-name"
  }
  key {
    name = "project-name"
    path = "${var.consul_infra_path}/input/project-name"
  }
  key {
    name = "environment"
    path = "${var.consul_base_path}/input/environment"
  }
  key {
    name = "country"
    path = "${var.consul_infra_path}/input/country"
  }
  key {
    name = "ceco"
    path = "${var.consul_infra_path}/input/ceco"
  }
  key {
    name = "owner"
    path = "${var.consul_infra_path}/input/owner"
  }
  key {
    name = "aws_region"
    path = "${var.consul_infra_path}/input/aws-region"
  }
  key {
    name = "service_name"
    path = "${var.consul_project_path}/input/service_name"
  }
  key {
    name = "db_environment"
    path = "${var.consul_project_path}/input/db_environment"
  }
}

data "consul_keys" "output" {
  key {
    name = "lb_listener_arn"
    path = "${var.consul_infra_path}/output/lb_listener_arn"
  }
  key {
    name = "aws_ecs_cluster-id"
    path = "${var.consul_infra_path}/output/aws_ecs_cluster-id"
  }
  key {
    name = "aws_security_group-id"
    path = "${var.consul_infra_path}/output/aws_security_group-id"
  }
  key {
    name = "aws_alb_target_group-id"
    path = "${var.consul_infra_path}/output/aws_alb_target_group-id"
  }
  key {
    name = "aws_alb_main-id"
    path = "${var.consul_infra_path}/output/aws_alb_main-id"
  }
  key {
    name = "aws_alb_listener-id"
    path = "${var.consul_infra_path}/output/aws_alb_listener-id"
  }
  key {
    name = "aws_alb_main-id"
    path = "${var.consul_infra_path}/output/aws_alb_main-id"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.consul_keys.input.var.vpc-id
  tags = {
    Name = data.consul_keys.input.var.private-subnet-id
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.consul_keys.input.var.vpc-id
  tags = {
    Name = data.consul_keys.input.var.public-subnet-id
  }
}

data "aws_vpc" "vpc" {
  id = data.consul_keys.input.var.vpc-id
}
