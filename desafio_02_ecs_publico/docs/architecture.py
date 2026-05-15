"""
Arquitetura — Desafio 02: VPC + ECS EC2 + ALB Multi-AZ

Para gerar o PNG:
    cd desafio_02_ecs_publico/docs && python3 architecture.py

Saída: ./architecture.png
"""
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, ECS, ECR, AutoScaling
from diagrams.aws.network import VPC, InternetGateway, RouteTable, ElasticLoadBalancing
from diagrams.aws.database import RDS
from diagrams.aws.management import Cloudwatch
from diagrams.aws.security import IAMRole
from diagrams.onprem.client import Users

graph_attr = {
    "fontsize": "14",
    "bgcolor": "white",
    "pad": "0.8",
    "splines": "ortho",
    "nodesep": "0.7",
    "ranksep": "1.0",
}

with Diagram(
    "Desafio 02 — VPC + ECS EC2 + ALB Multi-AZ",
    filename="architecture",
    outformat="png",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    user = Users("Usuário")
    ecr = ECR("ECR\nbia-repo-02")
    logs = Cloudwatch("CloudWatch Logs\n/ecs/bia-02")

    with Cluster("VPC bia-vpc-02 — 10.2.0.0/16"):
        igw = InternetGateway("IGW")
        rt  = RouteTable("RT pública\n0.0.0.0/0 → IGW")
        alb = ElasticLoadBalancing("ALB\nbia-02-alb\n:80")

        with Cluster("us-east-1a — 10.2.1.0/24"):
            ecs_a  = ECS("ECS Task\nBIA :8080")
            ec2_a  = EC2("ECS Instance\nt3.small")
            rds    = RDS("RDS PostgreSQL\nbia-rds-02\ndb.t3.micro")

        with Cluster("us-east-1b — 10.2.2.0/24"):
            ecs_b  = ECS("ECS Task\nBIA :8080")
            ec2_b  = EC2("ECS Instance\nt3.small")
            biadev = EC2("bia-dev\nt3.micro\n(build/migrations)")

        asg = AutoScaling("ASG + Capacity\nProvider")

    user  >> Edge(label="HTTP :80") >> igw >> rt >> alb
    alb   >> Edge(label=":8080") >> ecs_a
    alb   >> Edge(label=":8080") >> ecs_b
    ecs_a >> Edge(style="dashed") >> ec2_a
    ecs_b >> Edge(style="dashed") >> ec2_b
    asg   >> Edge(style="dotted") >> ec2_a
    asg   >> Edge(style="dotted") >> ec2_b
    ecs_a >> Edge(label="5432") >> rds
    ecs_b >> Edge(label="5432") >> rds
    biadev >> Edge(label="migrations") >> rds
    biadev >> Edge(label="docker push", style="dashed") >> ecr
    ecr   >> Edge(label="pull", style="dashed") >> ecs_a
    ecr   >> Edge(label="pull", style="dashed") >> ecs_b
    ecs_a >> Edge(style="dotted") >> logs
    ecs_b >> Edge(style="dotted") >> logs
