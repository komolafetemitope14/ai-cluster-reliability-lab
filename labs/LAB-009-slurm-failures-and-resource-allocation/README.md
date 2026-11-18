# LAB-009: Slurm Failures and Resource Allocation

## Overview

This lab investigates common Slurm workload and compute-node failures in a local, CPU-only HPC environment.

The objective is to practice diagnosing scheduling problems, application execution failures, and compute-daemon interruptions using Slurm commands, service checks, and repeatable Bash scripts.

The lab builds on LAB-008, which introduced Slurm batch jobs, resource allocation, and queue contention.

## Learning Objectives

- Distinguish temporary resource contention from an unschedulable resource request.
- Diagnose pending jobs using Slurm scheduling reasons.
- Identify application failures using job states, exit codes, and standard error.
- Verify the health of Slurm controller and compute-node services.
- Practice controlled compute-daemon interruption and recovery.
- Document findings and operational limitations clearly.

## Environment

| Component | Configuration |
|---|---|
| Operating system | Ubuntu Linux |
| Host | Lenovo ThinkPad T480 |
| Slurm version | 25.11.2 |
| Cluster | `ai-reliability-slurm` |
| Partition | `cpu` |
| Compute nodes | 1 |
| Configured CPUs | 2 |
| Configured Slurm memory | 2048 MiB |
| Job time limit | 30 minutes |
| GPU | None; CPU-only simulation |
| Services | MUNGE, `slurmctld`, `slurmd` |

This is a single-node learning environment. It is not intended to represent the redundancy or scale of a production HPC cluster.

## Repository Structure

```text
scripts/slurm/lab-009/
├── collect-baseline.sh
├── node-failure-preflight.sh
├── recover-compute-node.sh
├── test-failing-job.sh
├── test-node-interruption.sh
└── test-unschedulable-job.sh

slurm/jobs/lab-009/
└── failing-job.sh

labs/LAB-009-slurm-failures-and-resource-allocation/
└── README.md
```

Generated job output is stored under `slurm/output/lab-009/` and excluded from version control.

## Experiment 1: Unschedulable CPU Request

### Objective

Determine how Slurm handles a job requesting more CPU resources than the partition can provide.

### Procedure

Run:

```bash
bash scripts/slurm/lab-009/test-unschedulable-job.sh
```

The experiment submits a job requesting three CPUs on a compute node configured with only two CPUs.

### Observed Evidence

The job was accepted by `sbatch` but remained pending.

```text
JobId=4
JobState=PENDING
Reason=PartitionConfig
ReqTRES=cpu=3,mem=256M,node=1,billing=3
AllocTRES=(null)
```

The experiment safely cancelled the unschedulable job.

### Root Cause

The job requested three CPUs, exceeding the two CPUs configured for the available compute node.

This is different from temporary queue contention. Waiting for existing jobs to finish would not make a three-CPU allocation possible on the current node configuration.

### Resolution

Possible corrective actions include:

- Reduce the job's CPU request to fit available node capacity.
- Submit to a partition with suitable resources, if one exists.
- Increase appropriately configured cluster capacity in an environment where that change is authorized.

No cluster configuration change was required for this experiment.

## Experiment 2: Application Execution Failure

### Objective

Investigate a job that successfully receives resources but fails while executing its workload.

### Procedure

Run:

```bash
bash scripts/slurm/lab-009/test-failing-job.sh
```

The script submits `slurm/jobs/lab-009/failing-job.sh`, which deliberately exits with status code `42`.

### Observed Evidence

Slurm accepted the job and assigned job ID `5`.

The job progressed through pending and running states before leaving the active queue.

Slurm diagnostics reported:

```text
JobId=5
JobState=FAILED
Reason=NonZeroExitCode
ExitCode=42:0
RunTime=00:00:02
ReqTRES=cpu=1,mem=256M,node=1,billing=1
AllocTRES=cpu=1,mem=256M,node=1,billing=1
```

Standard error contained:

```text
ERROR: Simulated application processing failure.
```

### Root Cause

The job received its requested resources and began executing. The application then deliberately returned a nonzero exit code.

This was an application-level failure, not a resource allocation failure.

### Resolution and Troubleshooting Approach

- Inspect standard output and standard error.
- Check the job's final state and exit code.
- Confirm whether requested resources were allocated.
- Investigate the application command, dependencies, input data, and runtime environment.
- Correct the application problem before resubmitting.

For this demonstration, the nonzero exit was intentional.

### Additional Troubleshooting Finding

The first submission attempts failed because the batch script contained an extra line before its shebang.

Slurm requires the first bytes of a batch script to begin with `#!`.

The issue was resolved by removing the leading line and verifying the file header before resubmission.

This illustrates the value of checking script formatting separately from Bash syntax.

## Experiment 3: Compute-Daemon Interruption and Recovery

### Objective

Practice a controlled interruption of the Slurm compute daemon and verify that the local compute node can return to a healthy scheduling state.

### Safety Preparation

The preflight script checks:

- MUNGE service health.
- Slurm controller health.
- Slurm compute-daemon health.
- Partition and node state.
- Absence of active or pending jobs.

Run:

```bash
bash scripts/slurm/lab-009/node-failure-preflight.sh
```

The preflight completed successfully, with no active or pending jobs.

### Procedure

The controlled interruption script is:

```bash
bash scripts/slurm/lab-009/test-node-interruption.sh
```

It is designed to stop `slurmd` temporarily, observe scheduler state, and attempt recovery using an exit handler.

The recovery script is:

```bash
bash scripts/slurm/lab-009/recover-compute-node.sh
```

The recovery process starts `slurmd`, checks node status, and requests a node resume only when an appropriate failure or drain state is detected.

### Observed Recovery Evidence

The recovery output reported:

```text
[PASS] slurmd is active.
Observed node state: IDLE
No explicit resume requested.
```

Independent verification confirmed:

```text
munge: active
slurmctld: active
slurmd: active
```

Slurm reported:

```text
State=IDLE
CPUAlloc=0
SlurmdStartTime=2026-11-19T00:03:51
```

The job queue was empty.

### Interpretation

The compute daemon restarted successfully, and the node returned to an idle scheduling state.

No explicit node resume was necessary.

The retained evidence confirms successful recovery but does not establish that the controller marked the node `DOWN` during the brief interruption. That state should not be assumed.

### Operational Lesson

A service returning to an active state does not, by itself, prove that a compute node is ready for workloads.

Recovery verification should include both operating-system service status and Slurm scheduler state.

## Comparison of Failure Scenarios

| Scenario | Slurm evidence | Primary issue | Corrective action |
|---|---|---|---|
| Unschedulable job | `PENDING`, `PartitionConfig` | Request exceeds configured capacity | Adjust request or available capacity |
| Application failure | `FAILED`, `NonZeroExitCode`, `42:0` | Workload exited unsuccessfully | Inspect logs and application behavior |
| Compute-daemon interruption | Daemon restart; final node `IDLE` | Compute service availability | Restore daemon and verify scheduler state |

## Diagnostic Commands

```bash
sinfo
sinfo -N -l
squeue
scontrol show nodes
scontrol show job <job-id>
systemctl is-active munge slurmctld slurmd
```

For a specific failed job, standard output and standard error should also be inspected.

## Observability Limitations

Slurm accounting storage was disabled in this local environment.

The `sacct` command therefore did not provide historical job accounting records.

However, `scontrol show job` retained sufficient information during the experiment to identify the application failure and its exit code.

A production-oriented environment would benefit from persistent job accounting, monitoring, and alerting.

## Safety and Scope

- All experiments were performed on a local, single-node lab cluster.
- No GPU hardware was used.
- The unschedulable job was cancelled after diagnosis.
- The application failure was deliberate.
- The compute-daemon experiment included a recovery procedure.
- Recovery was verified through service status and Slurm node state.
- No Kubernetes cluster or unrelated project resources were intentionally modified.

## Customer Reliability Engineering Takeaways

This lab demonstrates several operational practices relevant to AI and HPC infrastructure support:

1. **Classify the failure before acting.** A pending job, failed application, and unavailable compute daemon require different investigations.
2. **Use scheduler evidence.** Job states, pending reasons, requested resources, and allocated resources help isolate problems.
3. **Correlate logs with exit codes.** Application stderr and Slurm job diagnostics provide complementary evidence.
4. **Prepare recovery before fault injection.** Preflight checks and recovery scripts reduce operational risk.
5. **Verify recovery at multiple layers.** Healthy services must be accompanied by a usable scheduler state.
6. **Document evidence limitations.** Do not infer node states or historical events that were not captured.

## Outcome

LAB-009 successfully demonstrated:

- Diagnosis of an unschedulable resource request.
- Diagnosis of a deliberately failing batch application.
- Controlled compute-daemon recovery with independent health verification.
- Reusable Bash scripts for Slurm troubleshooting.

Together with LAB-008, this lab completes the Slurm/HPC troubleshooting phase of the AI Cluster Reliability portfolio.
