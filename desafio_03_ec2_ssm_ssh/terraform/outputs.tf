# ─── IDs e IPs ────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "ID da VPC bia-vpc-03"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  description = "IP publico do bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID do bastion (para SSM)"
  value       = aws_instance.bastion.id
}

output "ec2_linux_private_ip" {
  description = "IP privado da EC2 Linux"
  value       = aws_instance.ec2_linux.private_ip
}

output "ec2_linux_instance_id" {
  description = "Instance ID da EC2 Linux (para SSM e ICE)"
  value       = aws_instance.ec2_linux.id
}

output "ec2_windows_private_ip" {
  description = "IP privado da EC2 Windows (null se desabilitada)"
  value       = var.enable_windows ? aws_instance.ec2_windows[0].private_ip : null
}

output "ec2_windows_instance_id" {
  description = "Instance ID da EC2 Windows (para SSM e ICE)"
  value       = var.enable_windows ? aws_instance.ec2_windows[0].id : null
}

output "rds_endpoint" {
  description = "Endpoint do RDS PostgreSQL"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "Porta do RDS PostgreSQL"
  value       = aws_db_instance.postgres.port
}

output "ice_endpoint_id" {
  description = "ID do EC2 Instance Connect Endpoint"
  value       = aws_ec2_instance_connect_endpoint.this.id
}

# ─── Metodo 1: SSH Direto ao Bastion ─────────────────────────────────────────
output "cmd_ssh_bastion" {
  description = "SSH direto para o bastion host"
  value       = "ssh -i ~/.ssh/bia-lab-03 ec2-user@${aws_instance.bastion.public_ip}"
}

# ─── Metodo 2: Tunnel SSH via Bastion ─────────────────────────────────────────
output "cmd_tunnel_ssh_linux" {
  description = "Abre tunnel SSH para a EC2 Linux privada (porta local 2222)"
  value       = "ssh -i ~/.ssh/bia-lab-03 -L 2222:${aws_instance.ec2_linux.private_ip}:22 ec2-user@${aws_instance.bastion.public_ip} -N -f"
}

output "cmd_ssh_via_tunnel_linux" {
  description = "Conecta na EC2 Linux via tunnel (execute apos abrir o tunnel)"
  value       = "ssh -i ~/.ssh/bia-lab-03 -p 2222 ec2-user@localhost"
}

output "cmd_tunnel_rdp_windows" {
  description = "Abre tunnel RDP para EC2 Windows privada (porta local 13389)"
  value       = var.enable_windows ? "ssh -i ~/.ssh/bia-lab-03 -L 13389:${aws_instance.ec2_windows[0].private_ip}:3389 ec2-user@${aws_instance.bastion.public_ip} -N -f" : "Windows desabilitado"
}

output "cmd_tunnel_rds" {
  description = "Abre tunnel para o RDS PostgreSQL via bastion (porta local 5433)"
  value       = "ssh -i ~/.ssh/bia-lab-03 -L 5433:${aws_db_instance.postgres.address}:5432 ec2-user@${aws_instance.bastion.public_ip} -N -f"
}

# ─── Metodo 3: EC2 Instance Connect (sem chave, chave temporaria 60s) ─────────
output "cmd_instance_connect_cli" {
  description = "EC2 Instance Connect via AWS CLI (injeta chave temporaria e conecta)"
  value       = "aws ec2-instance-connect ssh --instance-id ${aws_instance.bastion.id} --os-user ec2-user --region us-east-1"
}

# ─── Metodo 4: SSM Session Manager ───────────────────────────────────────────
output "cmd_ssm_bastion" {
  description = "SSM Session Manager para o bastion"
  value       = "aws ssm start-session --target ${aws_instance.bastion.id} --region us-east-1"
}

output "cmd_ssm_linux" {
  description = "SSM Session Manager para a EC2 Linux privada"
  value       = "aws ssm start-session --target ${aws_instance.ec2_linux.id} --region us-east-1"
}

output "cmd_ssm_port_forward_ssh_linux" {
  description = "SSM Port Forwarding para SSH na EC2 Linux (porta local 2222)"
  value       = "aws ssm start-session --target ${aws_instance.ec2_linux.id} --document-name AWS-StartPortForwardingSession --parameters '{\"portNumber\":[\"22\"],\"localPortNumber\":[\"2222\"]}' --region us-east-1"
}

output "cmd_ssm_port_forward_rdp_windows" {
  description = "SSM Port Forwarding para RDP na EC2 Windows via EC2 Linux (porta local 13389)"
  value       = var.enable_windows ? "aws ssm start-session --target ${aws_instance.ec2_linux.id} --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{\"host\":[\"${aws_instance.ec2_windows[0].private_ip}\"],\"portNumber\":[\"3389\"],\"localPortNumber\":[\"13389\"]}' --region us-east-1" : "Windows desabilitado"
}

output "cmd_ssm_port_forward_rds" {
  description = "SSM Port Forwarding para RDS PostgreSQL via EC2 Linux (porta local 5433)"
  value       = "aws ssm start-session --target ${aws_instance.ec2_linux.id} --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{\"host\":[\"${aws_db_instance.postgres.address}\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"5433\"]}' --region us-east-1"
}

# ─── Metodo 5: EC2 Instance Connect Endpoint ─────────────────────────────────
output "cmd_ice_tunnel_ssh_linux" {
  description = "Abre tunnel SSH via ICE Endpoint para EC2 Linux (porta local 2222)"
  value       = "aws ec2-instance-connect open-tunnel --instance-id ${aws_instance.ec2_linux.id} --remote-port 22 --local-port 2222 --region us-east-1"
}

output "cmd_ice_ssh_linux" {
  description = "SSH direto via ICE Endpoint (em outra aba, apos abrir o tunnel)"
  value       = "ssh -i ~/.ssh/bia-lab-03 -p 2222 ec2-user@localhost"
}

output "cmd_ice_tunnel_rdp_windows" {
  description = "Abre tunnel RDP via ICE Endpoint para EC2 Windows (porta local 13389)"
  value       = var.enable_windows ? "aws ec2-instance-connect open-tunnel --instance-id ${aws_instance.ec2_windows[0].id} --remote-port 3389 --local-port 13389 --region us-east-1" : "Windows desabilitado"
}
