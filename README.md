# Jerney DevSecOps Platform on Azure AKS

## Overview

Jerney is a full-stack blog platform deployed using a complete DevSecOps workflow.

The project demonstrates how to containerize a modern web application, provision cloud infrastructure with Terraform, deploy workloads on Kubernetes, and integrate security controls into the CI/CD pipeline.

---

## Project Objectives

The main objective of this project is to build a professional DevSecOps delivery chain including:

- Local application validation with Docker Compose
- Infrastructure provisioning with Terraform on Azure
- Kubernetes deployment on Azure Kubernetes Service
- Secure container image build and publication to GHCR
- Automated CI/CD pipeline using GitHub Actions
- Security scanning for code, dependencies, Dockerfiles, container images, Terraform, and Kubernetes manifests
- Kubernetes hardening using security contexts and NetworkPolicies

---

## Architecture

Developer
   |
   | Git push
   v
GitHub Repository
   |
   | GitHub Actions CI/CD
   v
GitHub Container Registry
   |
   | Pull images
   v
Azure Kubernetes Service
   |
   | Kubernetes Services
   v
Frontend React + Nginx
   |
   | /api
   v
Backend Node.js / Express
   |
   | PostgreSQL connection
   v
PostgreSQL Database

## Technology Stack
# Application
Frontend: React, Vite, Nginx
Backend: Node.js, Express
Database: PostgreSQL
# DevOps
Docker
Docker Compose
Kubernetes
Azure Kubernetes Service
Terraform
GitHub Actions
GitHub Container Registry
# Security Tools
ESLint
npm audit
Hadolint
Trivy
Checkov
Kubernetes NetworkPolicies
Kubernetes securityContext

## Repository Structure

jerney-devsecops/
├── backend/                 # Node.js backend API
│   ├── src/
│   ├── Dockerfile
│   ├── package.json
│   └── package-lock.json
│
├── frontend/                # React frontend served by Nginx
│   ├── src/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   └── package-lock.json
│
├── k8s/                     # Kubernetes manifests
│   └── jerney.yaml
│
├── terraform/               # Azure AKS infrastructure as code
│   ├── provider.tf
│   ├── variables.tf
│   ├── network.tf
│   ├── identity.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── .github/workflows/       # GitHub Actions pipeline
│   └── ci-cd.yml
│
├── docker-compose.yml       # Local development environment
├── .checkov.yml             # Checkov security scan configuration
├── .gitignore
└── README.md

## Local Deployment with Docker Compose
# Prerequisites

The following tools must be installed:

Git
Node.js
Docker Desktop
Docker Compose
Run the application locally
docker compose up --build -d

# Check running containers:

docker compose ps

# Access the application:

http://localhost