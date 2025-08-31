#!/usr/bin/env bash
set -euo pipefail
base="project-1-multicloud-gitops/terraform"
mkdir -p "$base/aws-eks" "$base/gcp-gke"

# ----- AWS EKS (us-west-1 by default) -----
cat > "$base/aws-eks/versions.tf" <<'HCL'
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws         = { source = "hashicorp/aws", version = ">= 5.0" }
    kubernetes  = { source = "hashicorp/kubernetes", version = ">= 2.28" }
  }
}
provider "aws" { region = var.region }
data "aws_availability_zones" "available" { state = "available" }
HCL

cat > "$base/aws-eks/variables.tf" <<'HCL'
variable "region"             { type = string  default = "us-west-1" }
variable "cluster_name"       { type = string  default = "demo-eks" }
variable "node_instance_type" { type = string  default = "t3.small" }
variable "desired_size"       { type = number  default = 2 }
variable "min_size"           { type = number  default = 1 }
variable "max_size"           { type = number  default = 3 }
HCL

cat > "$base/aws-eks/main.tf" <<'HCL'
locals {
  tags = { Project = "sre-showcase", Env = "demo" }
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_vpc" "this" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = local.tags
}
resource "aws_internet_gateway" "this" { vpc_id = aws_vpc.this.id tags = local.tags }

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = local.azs[0]
  tags = merge(local.tags, { "kubernetes.io/role/elb" = "1" })
}
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.10.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = local.azs[1]
  tags = merge(local.tags, { "kubernetes.io/role/elb" = "1" })
}

resource "aws_iam_role" "eks" {
  name               = "${var.cluster_name}-eks"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
}
data "aws_iam_policy_document" "eks_assume" {
  statement { actions = ["sts:AssumeRole"], principals { type = "Service", identifiers = ["eks.amazonaws.com"] } }
}
resource "aws_iam_role_policy_attachment" "eks" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = "1.29"
  vpc_config { subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id] }
  tags = local.tags
}

resource "aws_iam_role" "node" {
  name               = "${var.cluster_name}-node"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
}
data "aws_iam_policy_document" "node_assume" {
  statement { actions = ["sts:AssumeRole"], principals { type = "Service", identifiers = ["ec2.amazonaws.com"] } }
}
resource "aws_iam_role_policy_attachment" "node1" { role = aws_iam_role.node.name policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" }
resource "aws_iam_role_policy_attachment" "node2" { role = aws_iam_role.node.name policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" }
resource "aws_iam_role_policy_attachment" "node3" { role = aws_iam_role.node.name policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" }

resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  scaling_config { desired_size = var.desired_size, min_size = var.min_size, max_size = var.max_size }
  instance_types = [var.node_instance_type]
  tags = local.tags
}

output "cluster_name"     { value = aws_eks_cluster.this.name }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
HCL

cat > "$base/aws-eks/outputs.tf" <<'HCL'
output "region" { value = var.region }
HCL

# ----- GCP GKE -----
cat > "$base/gcp-gke/versions.tf" <<'HCL'
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = { source = "hashicorp/google", version = ">= 5.0" }
  }
}
provider "google" { project = var.project, region = var.region }
HCL

cat > "$base/gcp-gke/variables.tf" <<'HCL'
variable "project"      { type = string }
variable "region"       { type = string  default = "us-central1" }
variable "cluster_name" { type = string  default = "demo-gke" }
variable "node_count"   { type = number  default = 2 }
variable "machine_type" { type = string  default = "e2-standard-2" }
HCL

cat > "$base/gcp-gke/main.tf" <<'HCL'
resource "google_container_cluster" "this" {
  name                  = var.cluster_name
  location              = var.region
  remove_default_node_pool = true
  initial_node_count    = 1
  networking_mode       = "VPC_NATIVE"
}
resource "google_container_node_pool" "primary" {
  name       = "primary"
  cluster    = google_container_cluster.this.name
  location   = var.region
  node_count = var.node_count
  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
output "cluster_name" { value = google_container_cluster.this.name }
HCL

cat > "$base/gcp-gke/outputs.tf" <<'HCL'
output "region" { value = var.region }
HCL
