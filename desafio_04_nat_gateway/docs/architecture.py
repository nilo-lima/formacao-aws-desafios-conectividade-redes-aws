"""
Arquitetura — Desafio 04: NAT Gateway + ECS Privado

Para gerar o PNG:
    cd docs && python3 architecture.py

Saida: ./architecture.png
"""
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import ECS, ECR
from diagrams.aws.network import (
    VPC, InternetGateway, NATGateway, ALB, RouteTable
)
from diagrams.aws.database import RDS
from diagrams.onprem.client import Users

graph_attr = {
    "fontsize": "14",
    "bgcolor": "white",
    "pad": "0.6",
    "splines": "ortho",
    "nodesep": "0.7",
    "ranksep": "1.0",
}

with Diagram(
    "Desafio 04 - NAT Gateway + ECS Privado",
    filename="architecture",
    outformat="png",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    user = Users("Usuario")
    ecr = ECR("ECR\nbia:latest")

    with Cluster("VPC bia-04 (10.4.0.0/16)"):
        igw = InternetGateway("IGW")

        with Cluster("Subnets Publicas\n10.4.1.0/24 | 10.4.2.0/24"):
            alb = ALB("ALB\nporta 80")
            nat = NATGateway("NAT Gateway\nEIP 52.21.84.197")

        with Cluster("Subnets Privadas\n10.4.10.0/24 | 10.4.20.0/24"):
            ecs = ECS("ECS Fargate\nbia:latest  8080\nassign_public_ip=false")
            rds = RDS("RDS PostgreSQL\ndb.t3.micro\npublicly_accessible=false")

    user >> Edge(label="HTTP :80") >> igw >> alb
    alb >> Edge(label=":8080") >> ecs
    ecs >> Edge(label=":5432") >> rds
    ecs >> Edge(label="pull imagem\nECS agent\nCW Logs", style="dashed") >> nat
    nat >> Edge(style="dashed") >> igw
    igw >> Edge(style="dashed") >> ecr
