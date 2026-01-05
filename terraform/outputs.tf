output "consumer_service_name" {
  value = aws_ecs_service.consumer_service.name
}

output "consumer_task_definition" {
  value = aws_ecs_task_definition.consumer_task.family
}
