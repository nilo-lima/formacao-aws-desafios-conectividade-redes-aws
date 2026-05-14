"""
Arquitetura — Desafio 01: VPC + Subnet Pública

Para gerar o PNG:
    cd docs && python3 architecture.py

Saída: ./architecture.png
"""
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import InternetGateway, RouteTable, PublicSubnet
from diagrams.aws.management import SystemsManager
from diagrams.onprem.client import Users

graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.8",
    "splines": "ortho",
    "nodesep": "0.7",
    "ranksep": "1.0",
}

with Diagram(
    "Desafio 01 — VPC + Subnet Pública",
    filename="architecture",
    outformat="png",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    user = Users("Internet / Usuário")
    ssm  = SystemsManager("SSM Session\nManager")

    with Cluster("VPC: desafio-01  (10.0.0.0/16)\nDNS Hostnames & Resolution: enabled"):
        igw    = InternetGateway("IGW\ndesafio-01-igw")
        rt_pub = RouteTable("Route Table\n0.0.0.0/0 → IGW")

        with Cluster("Subnet Pública A — us-east-1a\n10.0.1.0/24  |  map_public_ip=true"):
            ec2 = EC2("bia-dev\nt3.micro\nSG: :80 :3001\nIAM: role-acesso-ssm")

        with Cluster("Subnet Pública B — us-east-1b\n10.0.2.0/24  |  reservada"):
            sub_b = PublicSubnet("(desafio 02+)")

    user   >> Edge(label="HTTP :80 / :3001") >> igw
    igw    >> rt_pub
    rt_pub >> Edge(label="subnet assoc") >> ec2
    rt_pub >> Edge(label="subnet assoc", style="dashed") >> sub_b
    ec2    >> Edge(label="SSM tunnel\nsem porta 22", style="dashed") >> ssm
