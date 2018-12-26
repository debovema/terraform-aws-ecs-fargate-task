data "aws_region" "current" {}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"

  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

module "ecs" {
  source      = "git::https://github.com/debovema/terraform-aws-ecs-fargate.git?ref=master"

  namespace   = "${module.label.namespace}"
  stage       = "${module.label.stage}"
  name        = "${module.label.namespace}"

  ecs_enabled = "${var.ecs_arn == ""}"
}

module "container_definition" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.6.0"
  container_name               = "${module.label.name}"
  container_image              = "${var.container_image}"

  command                      = ["${var.container_command}"]

  container_cpu                = "${var.container_cpu}"
  container_memory             = "${var.container_memory}"
  container_memory_reservation = "${var.container_memory_reservation}"

  port_mappings = [
    {
      containerPort = "${var.container_port}"
      hostPort      = "${var.container_port}" # Fargate implies containerPort == hostPort
      protocol      = "tcp"
    },
  ]

  log_options = {
    awslogs-region        = "${data.aws_region.current.name}"
    awslogs-group         = "${module.label.namespace}"
    awslogs-stream-prefix = "${module.label.name}"
  }
}

resource "aws_security_group" "ecs_security_group" {
  vpc_id      = "${module.ecs.vpc_id}"
  name        = "${module.label.name}-security-group"
  description = "Allow access to container port"
}

resource "aws_security_group_rule" "allow_container_port" {
  type              = "ingress"
  from_port         = "${var.container_port}"
  to_port           = "${var.container_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # TODO: allow only the right subnets
  security_group_id = "${aws_security_group.ecs_security_group.id}"
}

module "ecs_alb_service_task" {
  source                    = "git::https://github.com/cloudposse/terraform-aws-ecs-alb-service-task.git?ref=tags/0.6.2"

  namespace                 = "${module.label.namespace}"
  stage                     = "${module.label.stage}"
  name                      = "${module.label.name}-task"

  alb_target_group_arn      = "${module.ecs.alb_target_group_arn}"
  container_definition_json = "${module.container_definition.json}"
  container_name            = "${module.label.name}"
  container_port            = "${var.container_port}"

  task_cpu                  = "${var.container_cpu}"
  task_memory               = "${var.container_memory}"

  ecs_cluster_arn           = "${var.ecs_arn != "" ? var.ecs_arn : module.ecs.ecs_arn}"
  launch_type               = "FARGATE"
  vpc_id                    = "${module.ecs.vpc_id}"
  security_group_ids        = ["${aws_security_group.ecs_security_group.id}"]
  private_subnet_ids        = ["${module.ecs.private_subnet_ids}"]
}
