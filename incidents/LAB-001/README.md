# LAB-001: Kubernetes Training Workload Stuck in Pending

**Status:** Resolved  
**Date:** November 18, 2026  
**Environment:** Local Kubernetes v1.34.0 cluster using kind and Docker Engine  
**Incident type:** Kubernetes scheduling / CPU resource exhaustion (simulated request)  
**Severity:** Training exercise — not a production incident

## 1. Incident Summary

A simulated AI training workload could not be scheduled onto a Kubernetes node. The pod remained in the `Pending` state because its CPU resource request exceeded the available node capacity.

The incident was reproduced intentionally to demonstrate Kubernetes troubleshooting, resource capacity analysis, root-cause identification, and recovery verification.

## 2. Customer Impact

In a production environment, a similar scheduling failure could prevent a customer's AI training or inference workload from starting, delaying job execution.

In this lab, there was no real customer impact. The affected workload was a BusyBox container representing a training job.

## 3. Environment

- Operating system: Ubuntu Linux host
- Kubernetes: v1.34.0
- Cluster: `kind-ai-reliability-lab`
- Node: `ai-reliability-lab-control-plane`
- Container runtime: containerd 2.1.3
- Node allocatable CPU: 8 cores
- Existing CPU requests: 950m (0.95 core)
- CPU remaining for additional scheduling requests: approximately 7.05 cores

## 4. Symptoms

The original workload, `gpu-training-pending`, remained unscheduled.

Observed status:

```text
NAME                   READY   STATUS
gpu-training-pending   0/1     Pending
```

The Kubernetes scheduler reported:

```text
FailedScheduling
0/1 nodes are available: 1 Insufficient cpu.
```

The pod had no assigned node or pod IP.

## 5. Investigation

The following commands were used:

```bash
kubectl get pods -o wide
kubectl describe pod gpu-training-pending
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get nodes
kubectl describe node ai-reliability-lab-control-plane
```

The node was healthy and reported `Ready`.

Its allocatable CPU capacity was 8 cores, while existing workloads requested 950 millicores.

The affected pod requested 100 CPU cores, which exceeded the node's available capacity.

The node showed no memory, disk, or PID pressure.

## 6. Root Cause

The workload manifest specified an excessive CPU request:

```yaml
resources:
  requests:
    cpu: "100"
    memory: "1Gi"
  limits:
    cpu: "100"
    memory: "1Gi"
```

Kubernetes schedules pods according to resource requests and available allocatable node capacity.

Because the requested 100 CPUs exceeded the node's 8 allocatable CPUs, the scheduler could not assign the pod.

The failure was caused by workload resource configuration rather than node health.

## 7. Remediation

A separate corrected manifest was created to preserve the original failure scenario.

The corrected workload used:

```yaml
resources:
  requests:
    cpu: "500m"
    memory: "128Mi"
  limits:
    cpu: "1"
    memory: "256Mi"
```

The corrected pod was deployed as `gpu-training-fixed`.

## 8. Recovery Verification

The corrected workload successfully started:

```text
NAME                   READY   STATUS    RESTARTS
gpu-training-fixed     1/1     Running   0
```

The pod was scheduled onto:

```text
ai-reliability-lab-control-plane
```

Kubernetes reported:

```text
Successfully assigned default/gpu-training-fixed
```

Application logs confirmed successful container startup:

```text
Starting simulated AI training job
```

The original pod remained `Pending` to preserve evidence of the intentionally reproduced failure.

## 9. Preventive Measures

1. Validate CPU and memory requests before deploying workloads.
2. Compare resource requests with node allocatable capacity.
3. Use resource quotas and admission policies where appropriate.
4. Monitor pending pods and `FailedScheduling` events.
5. Document resource requirements for customer training workloads.
6. Escalate genuine cluster capacity shortages to the infrastructure team.

## 10. Customer Communication Example

**Initial update:**

We identified that the training workload is waiting for Kubernetes scheduling. The scheduler reports insufficient CPU capacity for the resources requested by the job. We are reviewing the workload configuration and available cluster capacity.

**Resolution update:**

We confirmed that the workload requested more CPU resources than the available node could provide. A corrected test workload with suitable resource requests was successfully scheduled and started. We recommend validating production resource requirements before applying equivalent changes.

## 11. Reproduction Files

- `../../kubernetes/workloads/gpu-training-pending.yaml` — original unschedulable workload
- `../../kubernetes/workloads/gpu-training-fixed.yaml` — corrected workload
- `../../kubernetes/cluster/kind-config.yaml` — kind cluster configuration

## 12. Lessons Learned

A Kubernetes node can be healthy while customer workloads remain unable to start.

The key troubleshooting evidence was the `FailedScheduling` event, supported by a comparison between pod CPU requests and node allocatable resources.

This lab demonstrates a reproducible Kubernetes scheduling failure and its recovery in a local environment without NVIDIA GPU hardware.
