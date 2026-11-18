# LAB-003: Kubernetes OOMKilled Investigation

**Status:** Resolved  
**Date:** November 18, 2026  
**Environment:** Kubernetes v1.34.0, kind, Ubuntu Linux host  
**Incident type:** Container memory exhaustion  
**Severity:** Training simulation — no production customer impact

## 1. Incident Summary

A simulated AI inference workload repeatedly exceeded its Kubernetes container memory limit and was terminated with the reason `OOMKilled`.

The container was configured with a memory limit of 64 MiB. Its Python application continuously allocated additional memory until the container exceeded the limit.

A corrected workload was deployed with bounded memory allocation. Recovery was verified through pod status, container restart count, and application logs.

## 2. Customer Impact

In a production AI inference environment, memory exhaustion can cause request failures, interrupted inference operations, and reduced service availability.

This exercise used a Python memory-allocation simulation. No real AI model was loaded, and no production customers were affected.

## 3. Symptoms

The original workload, `inference-oom`, exhibited repeated container restarts.

Observed Kubernetes status:

```text
NAME            READY   STATUS      RESTARTS
inference-oom   0/1     OOMKilled   5
```

The pod also entered `CrashLoopBackOff` between restart attempts.

## 4. Investigation

The following commands were used:

```bash
kubectl get pod inference-oom
kubectl describe pod inference-oom
kubectl logs inference-oom --previous
```

Kubernetes reported:

```text
Last State:     Terminated
  Reason:       OOMKilled
  Exit Code:    137
```

The container resource configuration was:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "32Mi"
  limits:
    cpu: "500m"
    memory: "64Mi"
```

Previous container logs showed steadily increasing memory allocations:

```text
Starting simulated AI inference memory test
Allocated approximately 8 MiB
Allocated approximately 16 MiB
Allocated approximately 24 MiB
Allocated approximately 32 MiB
Allocated approximately 40 MiB
Allocated approximately 48 MiB
Allocated approximately 56 MiB
```

The final logged allocation does not represent total container memory usage because Python and its runtime also consume memory.

## 5. Root Cause

The application continuously allocated memory in an infinite loop:

```python
allocations = []

while True:
    allocations.append(bytearray(8 * 1024 * 1024))
```

The application retained each allocation, causing memory consumption to grow.

The container exceeded its configured 64 MiB memory limit and was terminated by the container's memory-control mechanism.

Kubernetes subsequently restarted the container, resulting in repeated failures and restart backoff.

## 6. Remediation

A separate corrected workload, `inference-oom-fixed`, was created to preserve the original failing configuration for troubleshooting practice.

The corrected Python program allocated a fixed 16 MiB buffer:

```python
buffer = bytearray(16 * 1024 * 1024)
```

It then remained running without allocating additional buffers.

The container's original 64 MiB memory limit was retained.

## 7. Recovery Verification

The corrected pod reported:

```text
NAME                  READY   STATUS    RESTARTS
inference-oom-fixed   1/1     Running   0
```

Its application logs confirmed:

```text
Starting corrected AI inference memory test
Allocated a bounded buffer of 16 MiB
Simulated inference service running successfully
```

The corrected container remained healthy during the observed verification period.

## 8. Preventive Measures

1. Monitor container memory consumption and restart counts.
2. Configure appropriate Kubernetes memory requests and limits.
3. Avoid unbounded in-memory queues, caches, and allocations.
4. Investigate `OOMKilled` using container termination details and previous logs.
5. Load-test inference services using realistic request volumes and model memory requirements.
6. Establish alerts for memory utilization and repeated container restarts.
7. Review application memory behavior before increasing resource limits.

## 9. Example Customer Communication

### Initial Update

We identified repeated restarts affecting the simulated inference workload. Kubernetes reports that the container was terminated after exceeding its configured memory limit. We are reviewing memory allocation behavior and resource settings to determine the appropriate remediation.

### Resolution Update

The investigation identified unbounded memory allocation in the simulated inference application. We deployed a corrected workload with bounded memory usage and retained the existing memory limit. Verification confirmed that the corrected container was running successfully with zero restarts.

## 10. Reproduction Files

- `../../kubernetes/workloads/inference-oom.yaml` — intentionally memory-exhausting workload
- `../../kubernetes/workloads/inference-oom-fixed.yaml` — corrected workload

## 11. Lessons Learned

A Kubernetes container can be successfully scheduled and started but still fail because its application exceeds its memory limit.

`OOMKilled` identifies a memory-related termination, while `CrashLoopBackOff` describes Kubernetes delaying repeated restart attempts.

Effective troubleshooting requires examining both application behavior and Kubernetes resource limits.
