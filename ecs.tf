resource "aws_ecs_cluster" "my-ecs-cluster" {
    tags = {
      Name = "My-ECS-Cluster"
    }
    name = "My-ECS-Cluster"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
  name       = "ecs-task-execution-policy"
  roles      = [data.aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "my_ecs_task" {
  family                   = "my-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([{
    name  = "my-container"
    image = "430118853571.dkr.ecr.ap-south-1.amazonaws.com/my-node-app"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_ecs_service" "my_ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my-ecs-cluster.id
  task_definition = aws_ecs_task_definition.my_ecs_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-072749fc6111367ae", "subnet-088378c15782fa170"] # Replace with actual subnet IDs
    security_groups  = ["sg-07d7db81b22ccc498"] # Replace with actual security group ID
    assign_public_ip = true
  }

  desired_count = 1
}
