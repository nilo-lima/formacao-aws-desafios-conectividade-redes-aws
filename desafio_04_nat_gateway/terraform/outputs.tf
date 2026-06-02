output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "nat_eip" {
  description = "IP publico do NAT Gateway"
  value       = module.nat_gw.nat_eip_addresses
}

output "alb_dns_name" {
  description = "DNS do ALB - usar no VITE_API_URL ao construir a imagem"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "URI do repositorio ECR - usar no docker push"
  value       = aws_ecr_repository.bia.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "rds_endpoint" {
  description = "Endpoint do RDS (host sem porta)"
  value       = aws_db_instance.bia.address
}

output "smoke_test_cmd" {
  description = "Comando de smoke test - rode apos o ECS task estar RUNNING"
  value       = "curl -s -o /dev/null -w '%%{http_code}' http://${module.alb.alb_dns_name}/"
}
