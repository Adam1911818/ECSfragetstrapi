provider "aws" {
  region = "ap-south-1"
}


resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"
}

resource "aws_ecs_task_definition" "strapi_task_definition" {
  family                   = "strapi-task"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = "arn:aws:iam::533266978173:role/ECS-execution-role"
  task_role_arn      = "arn:aws:iam::533266978173:role/ECS-task-role"

  container_definitions = jsonencode([
    {
      name      = "strapi-container"
      image     = "533266978173.dkr.ecr.ap-south-1.amazonaws.com/adamstrapi"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "strapi_service1" {
  name            = "strapi-service-app"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0cd3d771cb3f4d587"]  # Specify your subnet IDs
    security_groups  = ["sg-0e5961a8a30708a80"]  # Specify your security group IDs
    assign_public_ip = true
  }
}
resource "aws_eip" "strapi_service1_ip" { }


# Route 53 DNS record for sub-domain
resource "aws_route53_record" "strapi_subdomain" {
  zone_id = "Z06607023RJWXGXD2ZL6M"
  name    = "adamstrapi.contentecho.in"
  type    = "A"
  ttl = "300"
  records = [aws_eip.strapi_service1_ip.public_ip]   
}
