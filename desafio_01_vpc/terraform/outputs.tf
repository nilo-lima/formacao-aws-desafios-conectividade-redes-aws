output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas (índice 0 = us-east-1a, 1 = us-east-1b)"
  value       = module.vpc.public_subnet_ids
}

output "ec2_instance_id" {
  description = "ID da instância EC2 bia-dev"
  value       = aws_instance.bia_dev.id
}

output "ec2_public_ip" {
  description = "IP público da instância bia-dev"
  value       = aws_instance.bia_dev.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da instância bia-dev"
  value       = aws_instance.bia_dev.public_dns
}

output "bia_url" {
  description = "URL de acesso à aplicação BIA (API)"
  value       = "http://${aws_instance.bia_dev.public_ip}:3001"
}

output "ssm_connect_cmd" {
  description = "Comando para acessar a instância via SSM Session Manager"
  value       = "aws ssm start-session --target ${aws_instance.bia_dev.id} --region ${var.region}"
}
