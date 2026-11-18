# LAB-006: Kubernetes Node Affinity, Taints, and Tolerations

## 1. Incident Summary

This lab investigates two Kubernetes scheduling constraints that can prevent workloads from being assigned to otherwise healthy nodes:

1. Required node affinity that does not match any available node.
2. A node taint that is not tolerated by the workload.

Both failures were reproduced on a local, CPU-only Kubernetes cluster. Corrected workloads were then deployed to demonstrate successful scheduling.

**Status:** Technical investigation and remediation verified.

## 2. Environment

| Component | Configuration |
|---|---|
| Operating system | Ubuntu Linux |
| Kubernetes distribution | kind (Kubernetes in Docker) |
| Kubernetes version | v1.34.0 |
| Cluster context | `kind-ai-reliability-lab` |
| Node | `ai-reliability-lab-control-plane` |
| Node status | Ready |
| Node architecture | amd64 |
| Node count | 1 |
| Container image | `busybox:1.36` |
| GPU hardware | None; workloads are simulations |

## 3. Incident A: Node Affinity Mismatch

### Symptoms

The Pod `affinity-pending` remained in the `Pending` state and was not assigned to a node.

Observed conditions:

- `PodScheduled=False`
- No Pod IP address
- No assigned node
- Scheduler reported a node affinity mismatch

### Failure Evidence

The Kubernetes scheduler reported:

```text
0/1 nodes are available:
1 node(s) didn't match Pod's node affinity/selector.
```

### Investigation

The workload defined a required node affinity rule:

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: accelerator
              operator: In
              values:
                - gpu
```

The only cluster node did not have an `accelerator=gpu` label.

Because the rule was required, Kubernetes could not place the Pod on that node.

### Root Cause

The workload's mandatory node affinity requirement did not match any available node labels.

The failure was caused by scheduling policy, not by a demonstrated CPU or memory shortage.

### Remediation

A separate corrected Pod, `affinity-fixed`, was deployed with a required affinity rule matching an existing node label:

```yaml
key: kubernetes.io/arch
operator: In
values:
  - amd64
```

This allowed the scheduler to select the existing node without falsely labeling the CPU-only machine as GPU-capable.

### Recovery Verification

The corrected workload reported:

- `Status=Running`
- `Ready=True`
- `PodScheduled=True`
- Zero container restarts
- Successful scheduling to `ai-reliability-lab-control-plane`

Application logs:

```text
Starting simulated AI inference workload
Node affinity requirement satisfied
Running on an amd64 node
```

The original `affinity-pending` Pod remained Pending, preserving evidence of the failed configuration.

## 4. Incident B: Untolerated Node Taint

### Symptoms

A temporary `NoSchedule` taint was applied to the cluster node:

```text
reliability-lab=restricted:NoSchedule
```

The Pod `taint-pending` did not define a matching toleration.

The scheduler initially rejected the Pod.

### Failure Evidence

The scheduler reported:

```text
0/1 nodes are available:
1 node(s) had untolerated taint
{reliability-lab: restricted}.
```

### Root Cause

The Pod lacked a toleration matching the node's `reliability-lab=restricted:NoSchedule` taint.

A `NoSchedule` taint prevents new Pods without matching tolerations from scheduling onto the affected node.

It does not evict Pods that are already running.

### Observed Scheduling Transition

The original `taint-pending` Pod later entered the Running state.

Its events showed both:

1. `FailedScheduling` due to the untolerated taint.
2. `Scheduled` after the scheduling restriction was no longer present.

A subsequent node inspection showed:

```text
Taints: <none>
```

The output confirmed that the temporary taint had been removed, although the exact action that removed it was not established from the captured evidence.

### Remediation

A separate Pod named `taint-tolerated` was configured with a matching toleration:

```yaml
tolerations:
  - key: reliability-lab
    operator: Equal
    value: restricted
    effect: NoSchedule
```

The Pod was deployed during the controlled taint experiment and successfully scheduled.

### Recovery Verification

The `taint-tolerated` Pod reported:

- `Status=Running`
- `Ready=True`
- `PodScheduled=True`
- Zero container restarts
- Successful assignment to the cluster node
- Matching toleration visible in the Pod description

Application logs:

```text
Starting simulated inference workload
Matching toleration configured
Successfully scheduled onto the tainted node
```

The temporary taint was removed after testing, and the node was confirmed to have no taints.

## 5. Comparison of Scheduling Mechanisms

| Mechanism | Purpose | Failure Condition | Resolution |
|---|---|---|---|
| Required node affinity | Restricts which nodes a Pod can use | No node matches the required label | Use an appropriate matching label or adjust the placement rule |
| Node taint | Restricts which Pods can schedule onto a node | Pod lacks a matching toleration | Add an appropriate toleration or remove the unnecessary taint |
| Toleration | Allows a Pod to be considered for a tainted node | Missing or mismatched toleration | Configure matching key, value, operator, and effect |

A toleration permits scheduling onto a tainted node but does not guarantee that Kubernetes will choose that node.

## 6. Production Troubleshooting Procedure

When investigating a Pending Pod:

1. Check Pod status and node assignment with `kubectl get pods -o wide`.
2. Inspect scheduler events using `kubectl describe pod`.
3. Review required node affinity and node selectors in the Pod specification.
4. Inspect node labels with `kubectl get nodes --show-labels`.
5. Inspect node taints using `kubectl describe node`.
6. Compare Pod tolerations with node taints.
7. Verify node readiness and available resources.
8. Apply the smallest safe configuration change.
9. Confirm successful scheduling, readiness, and application logs.
10. Remove temporary test configuration and document the result.

## 7. Customer Communication Simulation

### Initial Update

We identified a workload scheduling issue affecting the requested deployment. The Kubernetes scheduler is rejecting the Pod because its placement requirements do not match the available node configuration. We are reviewing node labels, affinity rules, and taints to determine the appropriate remediation.

### Resolution Update

The scheduling configuration was corrected in controlled test workloads. The node affinity workload successfully started using an existing node label, and the taint experiment confirmed that a matching toleration allows scheduling onto a restricted node. The temporary lab taint has been removed. We recommend validating placement policies against actual node capabilities before production deployment.

## 8. Prevention and Operational Recommendations

- Standardize node labels and document their intended meaning.
- Avoid labeling CPU-only nodes as GPU-capable.
- Validate required affinity rules before deployment.
- Audit node taints and workload tolerations.
- Use `NoSchedule` restrictions carefully on shared or single-node clusters.
- Monitor Pods that remain Pending.
- Include scheduler events in incident evidence.
- Remove temporary scheduling restrictions after troubleshooting.
- Use dedicated test clusters when validating disruptive scheduling policies.

## 9. Lab Manifests

- [Node affinity failure](../../kubernetes/workloads/lab-006/affinity-pending.yaml)
- [Corrected node affinity](../../kubernetes/workloads/lab-006/affinity-fixed.yaml)
- [Untolerated taint workload](../../kubernetes/workloads/lab-006/taint-pending.yaml)
- [Matching toleration workload](../../kubernetes/workloads/lab-006/taint-tolerated.yaml)

## 10. Key Lessons

This lab demonstrated that a healthy Kubernetes node may still be ineligible for a workload because of scheduling constraints.

Required node affinity controls which nodes satisfy a Pod's placement requirements. Taints restrict which Pods can schedule onto nodes, while tolerations allow exceptions to those restrictions.

Kubernetes scheduler events are essential for distinguishing resource shortages from policy mismatches.

The lab used CPU-only simulated inference workloads and did not perform real GPU inference or training.
