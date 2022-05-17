resource "aws_ecs_cluster" "test-cluster" {
  name = "Demo"
}

data "template_file" "testapp" {
  template = file("./templates/image/image.json")

  vars = {
    app_image      = "nginx:latest"
    app_port       = 80
    fargate_cpu    = "1024"
    fargate_memory = "2048"
    aws_region     = "us-east-1"
  }
}

resource "aws_ecs_task_definition" "test-def" {
  family                   = "my-app-task-definition"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  container_definitions    = data.template_file.testapp.rendered
}

resource "aws_ecs_service" "test-service" {
  name            = "service-app"
  cluster         = aws_ecs_cluster.test-cluster.id
  task_definition = aws_ecs_task_definition.test-def.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.security_group_ecs_sg]
    subnets          = var.private_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.aws_alb_target_group
    container_name   = "testapp"
    container_port   = 80
  }

 
}
