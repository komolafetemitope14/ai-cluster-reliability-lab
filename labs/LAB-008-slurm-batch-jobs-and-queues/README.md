# LAB-008: Slurm Batch Jobs and Queue Troubleshooting

## Objective

Deploy and operate a single-node Slurm cluster on a CPU-only Ubuntu laptop, submit batch jobs, observe resource contention, and diagnose a job that remains pending because insufficient compute resources are available.

This lab demonstrates practical HPC scheduling and customer reliability troubleshooting skills relevant to AI infrastructure operations.

## Environment

| Component | Configuration |
|---|---|
| Host | Lenovo ThinkPad T480 |
| Operating system | Ubuntu Linux |
| Workload manager | Slurm 25.11.2 |
| Authentication | MUNGE |
| Cluster name | `ai-reliability-slurm` |
| Controller | `enianyole-ThinkPad-T480` |
| Compute node | `enianyole-ThinkPad-T480` |
| Partition | `cpu` |
| Advertised CPUs | 2 |
| Advertised memory | 2,048 MiB |
| Maximum job duration | 30 minutes |
| GPU | None |

The cluster intentionally advertises fewer resources than the laptop physically provides. This reduces scheduling pressure during experiments but does not provide hard isolation from other workloads.

## Architecture

The lab uses three primary services:

- **MUNGE:** Authenticates Slurm communications.
- **slurmctld:** Controls scheduling and resource allocation.
- **slurmd:** Runs jobs on the compute node.

The controller and compute daemon run on the same laptop.

## Experiment 1: Cluster Initialization

Installed the Slurm packages, configured MUNGE authentication, and created a single-node Slurm configuration.

Verified that all three services were running:

```text
[RUNNING] munge
[RUNNING] slurmctld
[RUNNING] slurmd
```

The cluster reported an available compute node:

```text
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
cpu*         up      30:00      1   idle enianyole-ThinkPad-T480
```

**Result:** The controller and compute daemon communicated successfully, and the node was available for scheduling.

## Experiment 2: First Batch Job

Created a Bash batch job requesting:

- One node
- One CPU
- 256 MiB of memory
- A two-minute time limit

Submitted the job using `sbatch`.

The first submission attempt failed because the batch script contained an empty line before its interpreter declaration.

Slurm reported:

```text
sbatch: error: This does not look like a batch script.
sbatch: error: The first line must start with #!
```

Inspected the script header, removed the empty first line, and resubmitted successfully.

The corrected job was assigned **Job ID 1**.

Its output confirmed all five workload steps completed:

```text
Processing step 1 of 5
Processing step 2 of 5
Processing step 3 of 5
Processing step 4 of 5
Processing step 5 of 5
Job finished successfully.
```

**Result:** The cluster accepted, scheduled, and executed a batch job.

**Troubleshooting lesson:** A job submission error occurs before a job enters the scheduling queue. This must be distinguished from a job that is accepted but remains pending.

## Experiment 3: Resource Contention

### Scenario

A customer submits a batch job, but it remains pending even though the Slurm cluster is operational.

### Test Design

The compute node advertises two CPUs.

Submitted two jobs:

| Job | Job ID | CPU request | Workload |
|---|---|---|---|
| Resource holder | 2 | 2 CPUs | Sleep for 40 seconds |
| Waiting job | 3 | 1 CPU | Sleep for 5 seconds |

Job A was started first and allocated both available CPUs. Job B was submitted while Job A was running.

### Observations

The first queue observation showed Job B pending with no scheduling reason yet recorded.

Subsequent observations reported:

```text
JOBID NAME                       ST NODELIST(REASON)
3     lab008-waiting-job         PD (Resources)
2     lab008-resource-holder      R enianyole-ThinkPad-T480
```

Detailed job inspection confirmed:

```text
JobId=3 JobName=lab008-waiting-job
JobState=PENDING Reason=Resources
ReqTRES=cpu=1,mem=256M,node=1,billing=1
```

### Root Cause

Job A had allocated both CPUs available to the Slurm partition.

Job B required one CPU, but no CPU capacity was available for another job at that moment.

The pending state was therefore caused by resource contention, not a Slurm service outage.

### Resolution

Allowed Job A to finish and release its allocation.

Slurm subsequently executed Job B.

The verification script confirmed:

```text
Job A started
Job A completed

Job B started
Job B completed
```

After both jobs finished, `squeue` contained no active jobs and `sinfo` showed the compute node had returned to `idle`.

### Outcome

Successfully reproduced, diagnosed, and observed the resolution of a Slurm scheduling delay caused by resource contention.

## Customer-Facing Incident Summary

**Issue:** A submitted Slurm job remained in the pending state.

**Impact:** The affected workload could not begin execution while the requested compute resources were unavailable.

**Investigation:** Verified that the Slurm services and compute node were operational. Inspected the job queue and confirmed `Reason=Resources`.

**Root cause:** A running job had allocated all two CPUs advertised by the compute node.

**Resolution:** The running job completed and released its resources, allowing the waiting job to execute.

**Prevention:** Monitor pending-job reasons, resource allocations, and partition capacity. Review workload resource requests and expected concurrency.

## Operational Lessons

1. A healthy cluster can still contain pending jobs.
2. `Reason=Resources` indicates a scheduling capacity constraint, not necessarily a service failure.
3. `sinfo` provides partition and node availability information.
4. `squeue` shows active jobs and pending reasons.
5. `scontrol show job` provides detailed scheduling and resource-request information.
6. An empty queue alone does not prove successful job execution; job output and exit status should also be examined.
7. Slurm job-submission errors must be distinguished from scheduling and runtime failures.

## Reusable Scripts

| Script | Purpose |
|---|---|
| `scripts/slurm/check-environment.sh` | Inspect the local environment |
| `scripts/slurm/preflight.sh` | Check Slurm installation prerequisites |
| `scripts/slurm/install-slurm.sh` | Install Slurm packages |
| `scripts/slurm/discover-configuration.sh` | Discover node topology and configuration |
| `scripts/slurm/setup-munge.sh` | Configure MUNGE authentication |
| `scripts/slurm/configure-slurm.sh` | Configure the single-node cluster |
| `scripts/slurm/start-cluster.sh` | Start and inspect Slurm services |
| `scripts/slurm/submit-first-job.sh` | Submit the first batch job |
| `scripts/slurm/queue-demo.sh` | Reproduce queue contention |
| `scripts/slurm/verify-queue-demo.sh` | Verify experiment completion |

The batch job definition is located at:

`slurm/jobs/lab-008/first-job.sh`

Generated job output is excluded from Git through `.gitignore`.

## Limitations

- This is a single-node CPU-only learning environment, not a production HPC cluster.
- The configured CPU and memory values are scheduling limits, not full operating-system resource isolation.
- The experiments verified successful job output but did not independently verify final accounting exit codes.
- GPU scheduling, multi-node operation, and production accounting are outside the scope of this lab.

## Conclusion

LAB-008 demonstrates the ability to deploy a functional Slurm environment, execute batch jobs, investigate scheduling delays, identify resource contention, and communicate the findings in a customer-oriented reliability incident summary.
