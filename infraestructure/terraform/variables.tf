variable "consul_address" {
  type        = string
  description = "Consul Address"
}

variable "consul_token" {
  type        = string
  description = "Consul token"
}

variable "consul_base_path" {
  type = string
}

variable "consul_infra_path" {
  type = string
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "container_definition_image" {
  type        = string
  description = "URL for ECR image"
}

variable "repository_name" {
  type        = string
  description = "Github repo name"
}

variable "ENVIRONMENT" {
  type        = string
  description = "APP environment"
}

variable "consul_project_path" {
  type        = string
  description = "Specific Project parameters"
}
