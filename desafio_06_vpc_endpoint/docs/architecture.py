"""
Arquitetura - Desafio 06: VPC Endpoint + SSM + EC2 Instance Connect

Para gerar o PNG:
    cd docs && python3 architecture.py

Saida: ./architecture.png
"""
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC, PrivateSubnet, Endpoint
from diagrams.aws.security import IAMRole
from diagrams.aws.management import SystemsManager, Cloudwatch
from diagrams.aws.storage import S3
from diagrams.onprem.client import Users

graph_attr = {
    "fontsize": "15",
    "bgcolor": "white",
    "pad": "0.8",
    "splines": "ortho",
    "nodesep": "0.7",
    "ranksep": "1.0",
}

with Diagram(
    "Desafio 06 - VPC Endpoint + SSM + EC2 Instance Connect",
    filename="architecture",
    outformat="png",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    operador = Users("Operador\n(AWS CLI)")
    ssm_service = SystemsManager("AWS SSM\n(plano de controle)")
    s3_service = S3("Amazon S3\n(repos AL2023)")

    with Cluster("VPC bia-vpc-06 (10.0.0.0/16)\nSEM IGW funcional | SEM NAT Gateway"):
        with Cluster("Subnet Privada 10.0.2.0/24 (us-east-1a)"):
            ec2 = EC2("bia-ec2-06\n10.0.2.101\n(sem IP publico)")
            iam = IAMRole("IAM Role SSM\nAmazonSSMManaged\nInstanceCore")

            ep_ssm = Endpoint("ep-ssm\nep-ssmmessages\nep-ec2messages\n(Interface)")
            ep_eic = Endpoint("EC2 Instance\nConnect Endpoint\n(Interface)")
            ep_s3 = Endpoint("S3 Gateway\nEndpoint\n(Gateway - gratuito)")

        cw = Cloudwatch("CW Logs\n/bia/desafio-06/ec2")

    # Acesso do operador via SSM Session Manager
    operador >> Edge(label="aws ssm\nstart-session", color="blue") >> ep_ssm
    ep_ssm >> ec2
    ep_ssm >> Edge(style="dashed") >> ssm_service

    # Acesso do operador via EIC Endpoint (SSH)
    operador >> Edge(label="aws ec2-instance-\nconnect ssh", color="green") >> ep_eic
    ep_eic >> ec2

    # EC2 acessa S3 via Gateway Endpoint (dnf install)
    ec2 >> Edge(label="dnf install\n(sem internet)", style="dotted") >> ep_s3
    ep_s3 >> s3_service

    # IAM
    iam >> Edge(style="dotted") >> ec2

    # Observabilidade
    ec2 >> Edge(style="dotted") >> cw
