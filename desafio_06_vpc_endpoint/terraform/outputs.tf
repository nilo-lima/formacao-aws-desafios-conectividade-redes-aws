output "instance_id" {
  description = "ID da instancia EC2 privada"
  value       = aws_instance.main.id
}

output "instance_private_ip" {
  description = "IP privado da instancia EC2"
  value       = aws_instance.main.private_ip
}

output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_id" {
  description = "ID da subnet privada"
  value       = module.vpc.private_subnet_ids[0]
}

output "cmd_ssm_session" {
  description = "Comando para abrir sessao SSM Session Manager"
  value       = "aws ssm start-session --target ${aws_instance.main.id} --region ${var.region}"
}

output "cmd_eic_ssh" {
  description = "Comando para SSH via EC2 Instance Connect Endpoint"
  value       = "aws ec2-instance-connect ssh --instance-id ${aws_instance.main.id} --region ${var.region}"
}

output "cmd_ssm_check" {
  description = "Verificar se instancia esta registrada no SSM"
  value       = "aws ssm describe-instance-information --region ${var.region} --query \"InstanceInformationList[?InstanceId=='${aws_instance.main.id}'].[InstanceId,PingStatus,IPAddress]\" --output table"
}

output "cmd_ssm_port_forward" {
  description = "Port forward SSM para validar HTTP server local (porta 8080)"
  value       = "aws ssm start-session --target ${aws_instance.main.id} --region ${var.region} --document-name AWS-StartPortForwardingSession --parameters '{\"portNumber\":[\"8080\"],\"localPortNumber\":[\"8080\"]}'"
}
