"""
Arquitetura — Desafio 05: VPC + VPC Peering (multi-região)

Para gerar o PNG:
    cd docs && python3 architecture.py

Saida: ./architecture.png
"""
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC, InternetGateway, RouteTable, PublicSubnet
from diagrams.aws.management import Cloudwatch
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
    "Desafio 05 - VPC + VPC Peering (multi-regiao)",
    filename="architecture",
    outformat="png",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    user = Users("Operador")

    with Cluster("us-east-1\nbia-vpc-05-east1 (10.0.0.0/16)"):
        igw1 = InternetGateway("IGW east1")
        with Cluster("Public Subnet\n10.0.1.0/24 (us-east-1a)"):
            rt1 = RouteTable("RT publica")
            ec2_east1 = EC2("bia-ec2-east1")
        cw1 = Cloudwatch("CW Logs east1")

    with Cluster("us-east-2\nbia-vpc-05-east2 (10.1.0.0/16)"):
        igw2 = InternetGateway("IGW east2")
        with Cluster("Public Subnet\n10.1.1.0/24 (us-east-2a)"):
            rt2 = RouteTable("RT publica")
            ec2_east2 = EC2("bia-ec2-east2")
        cw2 = Cloudwatch("CW Logs east2")

    # SSH externo via IGW
    user >> Edge(label="SSH :22") >> igw1
    igw1 >> rt1 >> ec2_east1

    user >> Edge(label="SSH :22") >> igw2
    igw2 >> rt2 >> ec2_east2

    # VPC Peering - trafego cross-region via IP privado
    ec2_east1 >> Edge(
        label="pcx-090cd78943e7d584a\nICMP/SSH via IP privado",
        color="darkorange",
        style="dashed",
        fontcolor="darkorange",
    ) >> ec2_east2

    # CloudWatch
    ec2_east1 >> Edge(style="dotted") >> cw1
    ec2_east2 >> Edge(style="dotted") >> cw2
