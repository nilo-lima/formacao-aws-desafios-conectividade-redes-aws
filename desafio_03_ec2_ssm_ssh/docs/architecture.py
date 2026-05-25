"""
Arquitetura — Desafio 03: EC2 + SSH + SSM + Instance Connect

Para gerar o PNG:
    cd desafio_03_ec2_ssm_ssh/docs && python3 architecture.py

Saida: ./architecture.png
"""
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import InternetGateway, NATGateway
from diagrams.aws.database import RDS
from diagrams.aws.management import SystemsManager
from diagrams.aws.security import IAMRole
from diagrams.onprem.client import Users

graph_attr = {
    "fontsize": "13",
    "bgcolor": "white",
    "pad": "1.0",
    "splines": "ortho",
    "nodesep": "0.9",
    "ranksep": "1.2",
}

with Diagram(
    "Desafio 03 - EC2 + SSH + SSM + Instance Connect",
    filename="architecture",
    outformat="png",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    dev = Users("Desenvolvedor")
    ssm_svc = SystemsManager("SSM / ICE\nService Endpoints")
    iam = IAMRole("IAM Instance\nProfile (SSM)")

    with Cluster("VPC bia-vpc-03  |  10.0.0.0/16"):
        igw = InternetGateway("Internet\nGateway")

        with Cluster("Subnet Publica  10.0.1.0/24  us-east-1a"):
            bastion = EC2("Bastion Host\nAL2023 t3.micro\nporta 22 aberta")
            nat = NATGateway("NAT Gateway\n(saida SSM Agent)")

        with Cluster("Subnet Privada  10.0.10.0/24  us-east-1a"):
            ec2_linux = EC2("EC2 Linux\nAL2023 t3.micro\nSSM + ICE Endpoint")
            ec2_win = EC2("EC2 Windows\nWin 2022 t3.micro\nSSM + ICE Endpoint")

        with Cluster("Subnets Privadas  (DB Subnet Group)"):
            rds = RDS("RDS PostgreSQL 15\ndb.t3.micro  |  labdb\nsem acesso publico")

    # ── Metodo 1 & 3: SSH direto e Instance Connect ao bastion ──────────────
    dev >> Edge(
        label="1. SSH :22\n3. Instance Connect",
        color="#E67E22",
        style="bold",
    ) >> igw >> bastion

    # ── Metodo 2: Bastion + Tunnel SSH/RDP/DB ───────────────────────────────
    bastion >> Edge(
        label="2. Tunnel\nSSH / RDP / :5432",
        color="#E67E22",
        style="dashed",
    ) >> ec2_linux

    bastion >> Edge(color="#E67E22", style="dashed") >> ec2_win
    bastion >> Edge(color="#E67E22", style="dashed") >> rds

    # ── Metodo 4 & 5: SSM e ICE Endpoint ────────────────────────────────────
    dev >> Edge(
        label="4. SSM Session\n5. ICE Endpoint",
        color="#2980B9",
        style="bold",
    ) >> ssm_svc

    ssm_svc >> Edge(
        label="Session Manager\nPort Forwarding\nICE Tunnel",
        color="#2980B9",
        style="dashed",
    ) >> ec2_linux

    ssm_svc >> Edge(color="#2980B9", style="dashed") >> ec2_win

    # ── SSM Agent usa NAT para registrar ────────────────────────────────────
    ec2_linux >> Edge(
        label="SSM Agent\noutbound",
        color="#27AE60",
        style="dotted",
    ) >> nat >> igw

    iam >> ec2_linux
    iam >> ec2_win
    iam >> bastion
