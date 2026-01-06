output "consumer_service_name" {
  value = aws_ecs_service.consumer_service.name
}

output "consumer_task_definition" {
  value = aws_ecs_task_definition.consumer_task.family
}

output "alb_dns" {
  value = aws_lb.consumer_alb.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.consumer_repo.repository_url
}


