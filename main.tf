provider "aws" {
  region = var.aws_region

}

module "vpc" {
  source              = "./modules/vpc"
  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  vpc_private_subnets = var.vpc_private_subnets
  vpc_public_subnets  = var.vpc_public_subnets

}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
  depends_on = [
    module.vpc
  ]
}

module "iam" {
  source = "./modules/iam"
  ecs_task_execution_role = var.ecs_task_execution_role
  
}

module "alb" {
  source = "./modules/alb"
  aws_alb_name = var.aws_alb_name
  public_subnets = module.vpc.public_subnets
  security_groups = module.sg.alb-sg
  vpc_id = module.vpc.vpc_id
  depends_on = [
    module.sg
  ]
}

module "asg" {
  source = "./modules/asg"
  depends_on = [
    module.ecs
  ]
 
}

module "ecs" {
  source = "./modules/ecs"
  execution_role_arn = module.iam.ecs_task_execution_role
  aws_alb_target_group = module.alb.aws_alb_target_group
  security_group_ecs_sg = module.sg.ecs_sg
  private_subnets = module.vpc.private_subnets
   depends_on = [module.alb.testapp, module.iam.ecs_task_execution_role]
}


# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "testapp_log_group" {
  name              = "/ecs/testapp"
  retention_in_days = 30

  tags = {
    Name = "cw-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "myapp_log_stream" {
  name           = "test-log-stream"
  log_group_name = aws_cloudwatch_log_group.testapp_log_group.name
}
