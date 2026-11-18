
# AI Cluster Reliability Lab

A hands-on DevOps and Site Reliability Engineering portfolio focused on troubleshooting AI infrastructure, Kubernetes workloads, GPU scheduling, Linux compute nodes, and Slurm batch jobs.

## Project Goal

Simulate the responsibilities of a Customer Reliability Engineer supporting AI training and inference workloads.

This project demonstrates how to investigate failed jobs, diagnose infrastructure problems, restore service, communicate incidents, and prevent recurring failures.

## Portfolio Progress

**8 of 15 labs completed — 53.3%**

![Portfolio Progress](https://img.shields.io/badge/Portfolio_Progress-53.3%25-brightgreen)
![Completed Labs](https://img.shields.io/badge/Completed_Labs-8%2F15-blue)
![Current Phase](https://img.shields.io/badge/Current_Phase-Slurm%20%2F%20HPC-orange)

**Current phase:** Phase 3 — Slurm / HPC

**Latest completed lab:** LAB-008 — Slurm Batch Jobs and Queue Troubleshooting

**Next lab:** LAB-009 — Slurm Failures and Resource Allocation Troubleshooting

### Project Roadmap

| Phase | Focus Area | Labs | Progress | Status |
|---|---|---|---|---|
| 1 | Kubernetes Troubleshooting | LAB-001–004 | 4/4 | Completed |
| 2 | Advanced Kubernetes and GPU Scheduling | LAB-005–007 | 3/3 | Completed |
| 3 | Slurm / HPC | LAB-008–009 | 1/2 | In progress |
| 4 | Monitoring and Observability | LAB-010–011 | 0/2 | Not started |
| 5 | Infrastructure Automation | LAB-012–013 | 0/2 | Not started |
| 6 | Customer Reliability and Capstone | LAB-014–015 | 0/2 | Not started |
| **Total** | **AI Infrastructure Reliability** | **15 labs** | **8/15** | **53.3% complete** |

## Completed Labs

The following labs have been completed and documented.

| Lab | Focus Area | Documentation | Status |
|---|---|---|---|
| LAB-001 | Kubernetes Troubleshooting | [View LAB-001](incidents/LAB-001/README.md) | Completed |
| LAB-002 | Kubernetes Troubleshooting | [View LAB-002](incidents/LAB-002/README.md) | Completed |
| LAB-003 | Kubernetes Troubleshooting | [View LAB-003](incidents/LAB-003/README.md) | Completed |
| LAB-004 | Kubernetes Troubleshooting | [View LAB-004](incidents/LAB-004/README.md) | Completed |
| LAB-005 | Advanced Kubernetes and GPU Scheduling | [View LAB-005](incidents/LAB-005/README.md) | Completed |
| LAB-006 | Advanced Kubernetes and GPU Scheduling | [View LAB-006](incidents/LAB-006/README.md) | Completed |
| LAB-007 | Advanced Kubernetes and GPU Scheduling | [View LAB-007](incidents/LAB-007/README.md) | Completed |
| LAB-008 | Slurm Batch Jobs and Queue Troubleshooting | [View LAB-008](labs/LAB-008-slurm-batch-jobs-and-queues/README.md) | Completed |

## Upcoming Labs

| Lab | Planned Focus |
|---|---|
| LAB-009 | Slurm failures and resource allocation troubleshooting |
| LAB-010 | Prometheus and Grafana monitoring |
| LAB-011 | Alerting and observability troubleshooting |
| LAB-012 | Python infrastructure diagnostic tool |
| LAB-013 | Bash health checks and evidence collection |
| LAB-014 | Customer incident communication and root-cause analysis |
| LAB-015 | End-to-end AI infrastructure reliability capstone |

## Technical Skills Demonstrated

### Kubernetes Reliability

- Kubernetes cluster deployment using kind
- Workload troubleshooting and failure investigation
- Pod scheduling and resource diagnostics
- Simulated GPU scheduling scenarios
- Incident documentation and recovery verification

### Slurm and HPC Operations

- Slurm workload manager installation and configuration
- MUNGE authentication
- Single-node compute cluster administration
- Batch job submission using `sbatch`
- Queue inspection using `squeue`
- Partition and node inspection using `sinfo`
- Job diagnostics using `scontrol`
- Resource contention investigation
- Reusable Bash automation

### Reliability Engineering

- Structured troubleshooting workflows
- Evidence collection
- Root-cause investigation
- Recovery verification
- Operational documentation

## Technologies

- Linux (Ubuntu)
- Docker
- Kubernetes (kind)
- Bash
- Python (planned automation labs)
- Slurm Workload Manager
- MUNGE
- NVIDIA GPU scheduling concepts (simulated)
- Prometheus (planned)
- Grafana (planned)
- Git and GitHub

## Development Environment

The project runs on a Lenovo ThinkPad T480 using Ubuntu Linux.

Kubernetes workloads are tested using a local kind cluster.

Slurm experiments use a CPU-only, single-node cluster with a conservatively configured scheduling capacity of two CPUs and 2,048 MiB of memory.

The local environment is intended for learning and troubleshooting demonstrations rather than production deployment.

## GPU Hardware Availability

The development environment uses an Intel integrated GPU rather than an NVIDIA GPU.

GPU scheduling scenarios are explicitly simulated where possible.

Actual CUDA workloads, NVIDIA driver testing, and hardware GPU telemetry require compatible NVIDIA hardware.

## Repository Structure

```text
ai-cluster-reliability-lab/
├── incidents/
│   ├── LAB-001/
│   ├── LAB-002/
│   ├── LAB-003/
│   ├── LAB-004/
│   ├── LAB-005/
│   ├── LAB-006/
│   └── LAB-007/
├── labs/
│   └── LAB-008-slurm-batch-jobs-and-queues/
├── scripts/
│   └── slurm/
├── slurm/
│   ├── jobs/
│   │   └── lab-008/
│   └── output/  (ignored by Git)
└── README.md
```

Additional Kubernetes manifests, monitoring configurations, diagnostic scripts, and incident runbooks are maintained or added as the project develops.

## Security

No passwords, API tokens, private keys, MUNGE secret keys, or environment secrets are intentionally committed to this repository.

Generated Slurm job output is excluded from version control.

## Author

DevOps / Site Reliability Engineering portfolio focused on Customer Reliability Engineering for AI infrastructure.

