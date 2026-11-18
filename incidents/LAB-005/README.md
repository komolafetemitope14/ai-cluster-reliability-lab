# LAB-005: Kubernetes GPU Scheduling Failure and CPU Fallback

**Status:** Resolved through CPU-compatible workload adaptation

**Date:** November 18, 2026

**Environment:** Kubernetes v1.34.0, kind, Ubuntu Linux

**Incident Type:** GPU resource scheduling failure

**Severity:** Training simulation — no production customer impact

## 1. Incident Summary

A simulated AI training workload was submitted to a Kubernetes cluster requesting one NVIDIA GPU.

The Pod remained in the `Pending` state because the cluster's only node did not advertise any `nvidia.com/gpu` resources.

The Kubernetes scheduler reported an insufficient GPU resource error.

A separate CPU-compatible version of the simulated workload was deployed successfully, demonstrating a workload adaptation when GPU acceleration is not required.

No actual GPU training or AI model execution was performed.

## 2. Environment

- Cluster: `ai-reliability-lab`
- Kubernetes version: v1.34.0
- Node: `ai-reliability-lab-control-plane`
- Node status: Ready
- Allocatable CPU: 8
- NVIDIA GPU resources advertised: None
- Container image: `busybox:1.36`
- Namespace: `default`

## 3. Symptoms

The original Pod, `gpu-training-pending`, remained unscheduled.

Observed state:

```text
NAME                   READY   STATUS    NODE
gpu-training-pending   0/1     Pending   <none>
```

The scheduler reported:

```text
0/1 nodes are available: 1 Insufficient nvidia.com/gpu.
```

The event also indicated that preemption was not helpful for scheduling.

## 4. Investigation

### Step 1: Check Node Resources

Command:

```bash
kubectl describe node ai-reliability-lab-control-plane
```

The node was Ready and had CPU and memory available.

However, its Capacity and Allocatable sections did not include `nvidia.com/gpu`.

### Step 2: Inspect the Pending Pod

Commands:

```bash
kubectl get pods -o wide
kubectl describe pod gpu-training-pending
```

The Pod requested:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
    nvidia.com/gpu: "1"
  limits:
    cpu: "500m"
    memory: "256Mi"
    nvidia.com/gpu: "1"
```

The Pod condition showed:

```text
PodScheduled   False
```

### Step 3: Review Scheduler Events

Command:

```bash
kubectl get events --field-selector reason=FailedScheduling
```

The event confirmed that no node had sufficient advertised GPU resources.

## 5. Root Cause

The workload requested one NVIDIA GPU, but the Kubernetes node did not advertise the `nvidia.com/gpu` extended resource.

The scheduler therefore could not place the Pod.

This was a resource availability problem, not an application crash, DNS failure, or memory exhaustion issue.

## 6. Remediation

Because this was a CPU-only training environment, a separate CPU-compatible simulated workload was created.

The fallback manifest removed the NVIDIA GPU requirement while retaining modest CPU and memory requests.

File:

`kubernetes/workloads/lab-005/gpu-training-cpu-fallback.yaml`

Deployment command:

```bash
kubectl apply -f kubernetes/workloads/lab-005/gpu-training-cpu-fallback.yaml
```

This adaptation allowed the demonstration workload to run on the existing CPU-only node.

It did not provide GPU capacity or make GPU-dependent applications executable.

## 7. Recovery Verification

The fallback Pod successfully scheduled onto:

`ai-reliability-lab-control-plane`

Observed state:

```text
gpu-training-cpu-fallback   1/1   Running   0
```

Application logs:

```text
Starting CPU-compatible simulated training workload
GPU scheduling fallback demonstration
No NVIDIA GPU is being used
```

The original GPU-requesting Pod remained Pending, confirming that the underlying GPU capacity limitation still existed.

## 8. Production Investigation Approach

For a real GPU-dependent workload, the appropriate investigation would include:

- Checking whether GPU-equipped nodes are available and Ready.
- Verifying that the NVIDIA device plugin advertises GPU resources.
- Checking GPU allocation and competing workloads.
- Reviewing node selectors, affinity rules, and taints.
- Confirming driver and device plugin health.
- Adding appropriate GPU capacity when required.

A CPU fallback is only suitable when the application supports CPU execution and its performance requirements permit it.

## 9. Example Customer Communication

**Initial update:**

We have confirmed that the training workload cannot be scheduled because the cluster does not currently advertise the requested NVIDIA GPU resource. We are reviewing available capacity and workload requirements.

**Resolution update for this simulation:**

We deployed a CPU-compatible version of the demonstration workload and verified that it schedules and runs successfully. The original GPU-dependent workload remains unschedulable until suitable GPU resources are made available.

## 10. Preventive Measures

- Validate GPU capacity before submitting accelerator-dependent workloads.
- Monitor unschedulable Pods and FailedScheduling events.
- Verify device plugin registration on GPU nodes.
- Define appropriate workload placement rules.
- Maintain documented CPU fallback options where supported.
- Include resource availability checks in deployment procedures.

## 11. Reproduction Files

- `../../kubernetes/workloads/lab-005/gpu-training-pending.yaml`
- `../../kubernetes/workloads/lab-005/gpu-training-cpu-fallback.yaml`

## 12. Lessons Learned

A Kubernetes node can be healthy and Ready while lacking the specialized resources required by a workload.

A Pod remaining Pending with `Insufficient nvidia.com/gpu` indicates a scheduling resource mismatch.

Successful CPU fallback demonstrates workload adaptability, but does not resolve missing GPU capacity for workloads that genuinely require acceleration.
