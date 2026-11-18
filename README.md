# AI Cluster Reliability Lab

A hands-on DevOps and Site Reliability Engineering portfolio project focused on troubleshooting AI infrastructure, Kubernetes workloads, GPU scheduling, Linux compute nodes, and Slurm batch jobs.

## Project Goal

Simulate the responsibilities of a Customer Reliability Engineer supporting AI training and inference workloads.

The project demonstrates how to investigate failed jobs, diagnose infrastructure problems, restore service, communicate incidents, and prevent recurring failures.

## Technologies

- Linux (Ubuntu)
- Docker
- Kubernetes (kind)
- Python and Bash
- NVIDIA GPU scheduling concepts
- Slurm Workload Manager
- Prometheus
- Grafana
- Git and GitHub

## Project Labs

1. Kubernetes cluster deployment and troubleshooting
2. GPU scheduling and NVIDIA device-plugin fundamentals
3. Linux and Kubernetes failure investigations
4. Slurm batch scheduling and node troubleshooting
5. Infrastructure monitoring and alerting
6. Customer incident response and root-cause analysis

## GPU Hardware Availability

The initial development environment uses an Intel integrated GPU rather than an NVIDIA GPU.

GPU scheduling scenarios will therefore be explicitly simulated where possible. Actual CUDA workloads, NVIDIA driver testing, and hardware GPU telemetry require access to compatible NVIDIA hardware.

## Project Status

**Phase 1: Environment preparation and Kubernetes cluster setup — In progress.**

## Repository Structure

The repository will contain Kubernetes manifests, Slurm configurations, diagnostic scripts, monitoring configurations, runbooks, and documented incident investigations.

## Security

No passwords, API tokens, private keys, or environment secrets will be committed to this repository.

## Author

DevOps / SRE portfolio project.
