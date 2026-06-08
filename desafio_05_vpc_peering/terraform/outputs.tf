# ─── VPCs ───────────────────────────────────────────────────────────────────

output "vpc_east1_id" {
  description = "ID da VPC em us-east-1"
  value       = module.vpc_east1.vpc_id
}

output "vpc_east1_cidr" {
  description = "CIDR da VPC em us-east-1"
  value       = module.vpc_east1.vpc_cidr
}

output "vpc_east2_id" {
  description = "ID da VPC em us-east-2"
  value       = module.vpc_east2.vpc_id
}

output "vpc_east2_cidr" {
  description = "CIDR da VPC em us-east-2"
  value       = module.vpc_east2.vpc_cidr
}

# ─── VPC Peering ────────────────────────────────────────────────────────────

output "peering_connection_id" {
  description = "ID da VPC Peering Connection"
  value       = aws_vpc_peering_connection.east1_to_east2.id
}

output "peering_connection_status" {
  description = "Status da VPC Peering Connection (deve ser 'active')"
  value       = aws_vpc_peering_connection_accepter.east2.accept_status
}

# ─── EC2 ────────────────────────────────────────────────────────────────────

output "ec2_east1_public_ip" {
  description = "IP publico da EC2 em us-east-1"
  value       = aws_instance.east1.public_ip
}

output "ec2_east1_private_ip" {
  description = "IP privado da EC2 em us-east-1 (usado no ping/ssh cross-region)"
  value       = aws_instance.east1.private_ip
}

output "ec2_east2_public_ip" {
  description = "IP publico da EC2 em us-east-2"
  value       = aws_instance.east2.public_ip
}

output "ec2_east2_private_ip" {
  description = "IP privado da EC2 em us-east-2 (usado no ping/ssh cross-region)"
  value       = aws_instance.east2.private_ip
}

# ─── Comandos de Validacao ───────────────────────────────────────────────────

output "cmd_ssh_east1" {
  description = "Comando SSH para acessar EC2-A (east-1)"
  value       = "ssh -i ~/.ssh/bia-05 ec2-user@${aws_instance.east1.public_ip}"
}

output "cmd_ssh_east2" {
  description = "Comando SSH para acessar EC2-B (east-2)"
  value       = "ssh -i ~/.ssh/bia-05 ec2-user@${aws_instance.east2.public_ip}"
}

output "cmd_ping_east2_from_east1" {
  description = "Ping de EC2-A para o IP privado de EC2-B (execute dentro de EC2-A)"
  value       = "ping -c 4 ${aws_instance.east2.private_ip}"
}

output "cmd_ssh_east2_via_peering" {
  description = "SSH de EC2-A para EC2-B via peering (execute dentro de EC2-A)"
  value       = "ssh -i ~/.ssh/bia-05 ec2-user@${aws_instance.east2.private_ip}"
}
