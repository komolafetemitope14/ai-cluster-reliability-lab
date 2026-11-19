AI Cluster Reliability Lab
A hands-on, 15-lab portfolio focused on Customer Reliability Engineering for AI Infrastructure, covering Kubernetes troubleshooting, GPU scheduling concepts, Slurm/HPC workload management, monitoring, automation, and customer-facing incident response.

This project demonstrates practical troubleshooting, incident diagnosis, recovery, and operational documentation using a local Linux-based lab environment.

GitHub: https://github.com/komolafetemitope14/ai-cluster-reliability-lab
Portfolio Progress
13 of 15 labs completed — 86.7%

Completed phases: 5 of 6

Current phase: Phase 6 — Customer Reliability and Capstone

Latest completed lab: LAB-013 — Bash Health Checks and Evidence Collection

Next lab: LAB-014 — Customer Incident Communication and Root Cause Analysis
Six-Phase Roadmap
Phase	Focus Area	Labs	Progress	Status
1	Kubernetes Troubleshooting	LAB-001–004	4/4	Completed
2	Advanced Kubernetes Scheduling	LAB-005–007	3/3	Completed
3	Slurm / HPC	LAB-008–009	2/2	Completed
4	Monitoring and Observability	LAB-010–011	2/2	Completed
5	Reliability Automation	LAB-012–013	2/2	Completed
6	Customer Reliability and Capstone	LAB-014–015	0/2	Not started
Total	AI Infrastructure Reliability	15 labs	13/15	86.7% complete


Completed Labs
The following labs have been implemented and published.
Lab	Focus	Documentation	Status
LAB-001	Kubernetes Troubleshooting	[View LAB-001](incidents/LAB-001/README.md)	Completed
LAB-002	Kubernetes Troubleshooting	[View LAB-002](incidents/LAB-002/README.md)	Completed
LAB-003	Kubernetes Troubleshooting	[View LAB-003](incidents/LAB-003/README.md)	Completed
LAB-004	Kubernetes Troubleshooting	[View LAB-004](incidents/LAB-004/README.md)	Completed
LAB-005	Advanced Kubernetes Scheduling	[View LAB-005](incidents/LAB-005/README.md)	Completed
LAB-006	Advanced Kubernetes Scheduling	[View LAB-006](incidents/LAB-006/README.md)	Completed
LAB-007	Advanced Kubernetes Scheduling	[View LAB-007](incidents/LAB-007/README.md)	Completed
LAB-008	Slurm Batch Jobs and Queue Troubleshooting	[View LAB-008](labs/LAB-008-slurm-batch-jobs-and-queues/README.md)	Completed
LAB-009	Slurm Failures and Resource Allocation Troubleshooting	[View LAB-009](labs/LAB-009-slurm-failures-and-resource-allocation/README.md)	Completed
LAB-010	Prometheus and Grafana Monitoring	[View LAB-010](labs/LAB-010-prometheus-and-grafana-monitoring/README.md)	Completed
LAB-011	Alerting and Observability Troubleshooting	[View LAB-011](labs/LAB-011-alerting-and-observability-troubleshooting/README.md)	Completed
LAB-012	Python Diagnostic Automation	[View LAB-012](labs/LAB-012-python-diagnostic-automation/README.md)	Completed
LAB-013	Bash Health Checks and Evidence Collection	[View LAB-013](labs/LAB-013-bash-health-checks-and-evidence-collection/README.md)	Completed


Upcoming Labs
Lab	Planned Focus	Phase
LAB-014	Customer Incident Communication and Root Cause Analysis	Customer Reliability
LAB-015	Integrated AI Infrastructure Reliability Capstone	Capstone


The upcoming labs are planned work and are not yet implemented.
Technical Environment
The portfolio is developed using a local CPU-only infrastructure environment.
Workstation
- Hardware: Lenovo ThinkPad T480
- Operating system: Ubuntu Linux
- Processor: Intel Core i7-8550U
- Logical CPUs: 8
- Memory: Approximately 14 GiB
- GPU: No NVIDIA GPU
The environment uses CPU-based simulations for GPU scheduling concepts where appropriate.
Kubernetes Environment
- Container runtime: Docker Engine
- Local Kubernetes: kind
- Cluster name: ai-reliability-lab
- Kubernetes context: kind-ai-reliability-lab
- Topology: Single control-plane node
- Kubernetes version: v1.34.0
The existing kind cluster is reused across Kubernetes labs to conserve resources and preserve continuity.
Slurm / HPC Environment
- Slurm version: 25.11.2
- Cluster name: ai-reliability-slurm
- Partition: cpu
- Compute nodes: 1
- Configured CPUs: 2
- Configured memory: 2048 MiB
- Partition time limit: 30 minutes
- Authentication: MUNGE
Slurm is installed locally, with the controller and compute daemon operating on the same workstation.

This environment supports repeatable learning exercises but does not reproduce the redundancy, capacity, or GPU hardware of a production AI cluster.
Phase 1 — Kubernetes Troubleshooting
Status: Completed

Labs: LAB-001 through LAB-004

This phase focuses on diagnosing and resolving Kubernetes workload and cluster issues.

Key troubleshooting practices include:
- Inspecting workloads and pod states.
- Reading container logs and Kubernetes events.
- Investigating workload configuration and scheduling.
- Identifying causes of service degradation.
- Verifying recovery after corrective actions.
- Documenting incidents and operational evidence.
Documentation
- [LAB-001](incidents/LAB-001/README.md)
- [LAB-002](incidents/LAB-002/README.md)
- [LAB-003](incidents/LAB-003/README.md)
- [LAB-004](incidents/LAB-004/README.md)
Phase 2 — Advanced Kubernetes Scheduling
Status: Completed

Labs: LAB-005 through LAB-007

This phase explores advanced Kubernetes scheduling and AI infrastructure concepts in a CPU-only learning environment.

Topics include:
- Workload resource requests and limits.
- Scheduling constraints.
- Node selection and placement.
- GPU scheduling concepts using simulation.
- Diagnosing unschedulable workloads.
- Interpreting scheduler events and resource availability.
Documentation
- [LAB-005](incidents/LAB-005/README.md)
- [LAB-006](incidents/LAB-006/README.md)
- [LAB-007](incidents/LAB-007/README.md)
Phase 3 — Slurm / HPC Troubleshooting
Status: Completed

Labs: LAB-008 and LAB-009

This phase introduces Slurm workload management and common HPC troubleshooting workflows.
LAB-008 — Slurm Batch Jobs and Queue Troubleshooting
LAB-008 demonstrates:
- Installing and configuring a local Slurm environment.
- Verifying MUNGE authentication.
- Starting and checking Slurm services.
- Submitting batch jobs.
- Inspecting partitions, nodes, and queues.
- Observing resource contention.
- Distinguishing running jobs from pending jobs.
A queue-contention experiment demonstrated a job pending with:
Reason=Resources
The pending job proceeded after resources became available.

[Read LAB-008](labs/LAB-008-slurm-batch-jobs-and-queues/README.md)
LAB-009 — Slurm Failures and Resource Allocation Troubleshooting
LAB-009 investigates three different failure scenarios.

Experiment 1: Unschedulable resource request

A job requested three CPUs from a node configured with two CPUs.

Observed scheduler evidence:
JobState=PENDING
Reason=PartitionConfig
ReqTRES=cpu=3,mem=256M,node=1,billing=3
The job was cancelled after diagnosis.

Experiment 2: Application execution failure

A batch job successfully received resources but deliberately exited with code 42.

Observed evidence:
JobState=FAILED
Reason=NonZeroExitCode
ExitCode=42:0
The application error was also captured in standard error.

Experiment 3: Compute-daemon interruption and recovery

A controlled slurmd interruption and recovery procedure was exercised.

Recovery verification confirmed:
slurmd: active
State=IDLE
CPUAlloc=0
The cluster returned to a healthy state without requiring an explicit node resume.

The retained evidence did not establish that the controller marked the node DOWN during the brief interruption.

Additional finding: Slurm accounting storage was disabled in the local environment, limiting historical job accounting.

[Read LAB-009](labs/LAB-009-slurm-failures-and-resource-allocation/README.md)
Phase 4 — Monitoring and Observability
Status: Completed

Labs: LAB-010 and LAB-011

This phase established Prometheus and Grafana monitoring in the existing kind Kubernetes cluster and demonstrated a controlled alerting incident.
LAB-010 — Prometheus and Grafana Monitoring
LAB-010 implemented:
- Prometheus metrics collection and target health verification.
- Kubernetes API server monitoring.
- Grafana deployment and Prometheus datasource provisioning.
- Metrics exploration through the Prometheus and Grafana interfaces.
- Deployment configuration and troubleshooting documentation.
[Read LAB-010](labs/LAB-010-prometheus-and-grafana-monitoring/README.md)
LAB-011 — Alerting and Observability Troubleshooting
LAB-011 demonstrated:
- Configuring and validating Prometheus alert rules.
- Triggering a controlled synthetic alert and observing the Firing state.
- Investigating Kubernetes ConfigMap propagation delays.
- Restoring the healthy rule and reloading Prometheus without a pod restart.
- Verifying both alerts returned to Inactive with rule health OK.
- Collecting evidence and creating a reusable Bash health-check script.
The experiment was synthetic; it did not involve a real infrastructure outage or Alertmanager notification delivery.

[Read LAB-011](labs/LAB-011-alerting-and-observability-troubleshooting/README.md)
Phase 5 — Reliability Automation
Status: Completed — 2 of 2 labs completed

Labs: LAB-012 and LAB-013

This phase focuses on reducing repetitive troubleshooting work through read-only Python and Bash diagnostics and structured evidence collection.
LAB-012 — Python Diagnostic Automation
Implemented a read-only Python diagnostic tool covering Kubernetes, Slurm, and Prometheus. The tool generates JSON reports, passed nine automated tests, and correctly detected a controlled monitoring connectivity failure.

[Read LAB-012](labs/LAB-012-python-diagnostic-automation/README.md)
LAB-013 — Bash Health Checks and Evidence Collection
Implemented read-only Bash health checks for Kubernetes, Slurm, and Prometheus, plus timestamped incident evidence collection with private archives and collection summaries. Healthy and controlled-failure scenarios were validated, and all seven automated tests passed.

[Read LAB-013](labs/LAB-013-bash-health-checks-and-evidence-collection/README.md)
Phase 6 — Customer Reliability and Capstone
Status: Not started

Labs: LAB-014 and LAB-015

This phase will connect infrastructure troubleshooting with customer-facing reliability practices.
LAB-014 — Customer Incident Communication and RCA
Planned objectives:
- Write clear customer incident updates.
- Distinguish symptoms, impact, and root cause.
- Document investigation timelines.
- Produce a structured root cause analysis.
- Recommend corrective and preventive actions.
LAB-015 — Integrated AI Infrastructure Reliability Capstone
The final lab will combine Kubernetes, Slurm, monitoring, automation, and incident communication into an end-to-end troubleshooting scenario.
Troubleshooting Methodology
Across the portfolio, incidents follow a consistent operational approach:
1. Establish a baseline: Check the environment and expected healthy state.
2. Identify symptoms: Determine what is failing and what is affected.
3. Collect evidence: Gather logs, events, resource information, and service status.
4. Form a hypothesis: Identify the most likely failure category.
5. Test safely: Use controlled experiments and reversible changes.
6. Apply corrective action: Address the confirmed problem.
7. Verify recovery: Check both service health and workload behavior.
8. Document findings: Record evidence, limitations, root cause, and lessons learned.
This methodology emphasizes reproducibility, safety, and clear communication.
Common Diagnostic Commands
Kubernetes
kubectl config current-context
kubectl get nodes
kubectl get pods -A
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl get events -A
Slurm
sinfo
sinfo -N -l
squeue
scontrol show nodes
scontrol show job <job-id>
systemctl is-active munge slurmctld slurmd
Git
git status
git diff --check
git log --oneline -5
git push origin main
Commands are examples. Replace placeholders with the relevant resource names.
Repository Organization
The repository contains incident documentation, lab guides, reusable scripts, Slurm job definitions, and infrastructure configuration.

Key directories include:
ai-cluster-reliability-lab/
├── README.md
├── incidents/
│   ├── LAB-001/
│   ├── LAB-002/
│   ├── LAB-003/
│   ├── LAB-004/
│   ├── LAB-005/
│   ├── LAB-006/
│   └── LAB-007/
├── labs/
│   ├── LAB-008-slurm-batch-jobs-and-queues/
│   ├── LAB-009-slurm-failures-and-resource-allocation/
│   ├── LAB-010-prometheus-and-grafana-monitoring/
│   ├── LAB-011-alerting-and-observability-troubleshooting/
│   ├── LAB-012-python-diagnostic-automation/
│   └── LAB-013-bash-health-checks-and-evidence-collection/
├── scripts/
│   └── slurm/
│       └── lab-009/
│           ├── collect-baseline.sh
│           ├── node-failure-preflight.sh
│           ├── recover-compute-node.sh
│           ├── test-failing-job.sh
│           ├── test-node-interruption.sh
│           └── test-unschedulable-job.sh
└── slurm/
    └── jobs/
        └── lab-009/
            └── failing-job.sh
This is a simplified view of the repository, not an exhaustive file listing.

Generated Slurm output files are excluded from version control.
Safety and Operational Boundaries
This portfolio is built in a local learning environment.
- Infrastructure experiments are designed to be repeatable and controlled.
- Existing Kubernetes and Slurm environments are reused where possible.
- Destructive operations are avoided unless specifically required and documented.
- Recovery procedures are prepared before fault-injection experiments.
- Sensitive authentication material, including MUNGE keys, must not be committed.
- Generated job output and temporary evidence should be reviewed before publication.
- CPU-based simulations are identified as simulations rather than real GPU experiments.
- Observed evidence is distinguished from expected or hypothetical behavior.
Skills Demonstrated
The completed and planned labs collectively target skills relevant to Customer Reliability Engineering and AI Infrastructure operations:
- Linux troubleshooting and service management.
- Kubernetes workload diagnostics.
- Kubernetes scheduling and resource allocation.
- Slurm batch scheduling and queue management.
- HPC workload failure diagnosis.
- Compute-node service recovery.
- Prometheus and Grafana observability.
- Python and Bash automation.
- Incident investigation and root cause analysis.
- Customer-facing technical communication.
- Operational documentation and reproducible troubleshooting.
Skills from upcoming labs will be demonstrated as those labs are completed.
Current Milestone
Completed: LAB-001 through LAB-013

Portfolio progress: 13/15 labs — 86.7%

Completed phases: Kubernetes Troubleshooting, Advanced Kubernetes Scheduling, Slurm/HPC Troubleshooting, Monitoring and Observability, and Reliability Automation.

Latest completed implementation: LAB-013 — Bash Health Checks and Evidence Collection.

Next implementation: LAB-014 — Customer Incident Communication and Root Cause Analysis.

The remaining two labs will cover customer incident communication and the integrated reliability capstone.
Repository
AI Cluster Reliability Lab

https://github.com/komolafetemitope14/ai-cluster-reliability-lab
