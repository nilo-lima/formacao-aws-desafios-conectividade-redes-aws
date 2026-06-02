#!/usr/bin/env bash
# Verifica se há recursos órfãos após destroy
set -euo pipefail
TAG_VALUE="mai2026-desafio-04"
echo "▶ Verificando recursos remanescentes com tag Challenge=$TAG_VALUE"
aws resourcegroupstaggingapi get-resources   --tag-filters "Key=Challenge,Values=$TAG_VALUE"   --query 'ResourceTagMappingList[*].[ResourceARN]' --output table
echo ""
echo "▶ EBS órfãos (available):"
aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[*].[VolumeId,Size,CreateTime]' --output table
echo ""
echo "▶ EIPs não associadas:"
aws ec2 describe-addresses --query 'Addresses[?AssociationId==null].[AllocationId,PublicIp]' --output table
