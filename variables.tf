variable "namespace" {
  description = "Namespace"
  type        = "string"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = "string"
}

variable "name" {
  description = "Name  (e.g. `app` or `cluster`)"
  type        = "string"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "ecs_arn" {
  type        = "string"
  default     = ""
  description = "Optional ECS ARN, if not provided a new ECS cluster will be created"
}

variable "container_image" {
  type        = "string"
  description = "The container image to use"
}

variable "container_command" {
  type        = "list"
  default     = []
  description = "The list of commands for the container"
}

variable "container_cpu" {
  type        = "string"
  default     = "512"
  description = "The number of vCPU to allocate (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "container_memory" {
  type        = "string"
  default     = "1024"
  description = "The amount of memory to allocate (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "container_memory_reservation" {
  type        = "string"
  default     = "512"
  description = "The amount of memory to reserve (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "container_port" {
  type        = "string"
  description = "The port on which the container is listening"
  default     = "80"
}