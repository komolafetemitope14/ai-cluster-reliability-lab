# LAB-007: Kubernetes Readiness and Liveness Probe Failures

## 1. Incident Summary

This lab investigates Kubernetes readiness and liveness probe failures using simulated AI inference workloads.

Two failure scenarios were reproduced:

1. A readiness probe repeatedly failed because the application had not created the expected readiness file.
2. A liveness probe repeatedly failed because the expected health file was missing, causing Kubernetes to restart the container.

Corrected workloads demonstrated readiness recovery and stable liveness behavior.

**Status:** Technical investigation complete; documentation and cleanup pending.

## 2. Environment

| Component | Configuration |
|---|---|
| Operating system | Ubuntu Linux |
| Kubernetes distribution | kind (Kubernetes in Docker) |
| Kubernetes version | v1.34.0 |
| Cluster | `ai-reliability-lab` |
| Node | `ai-reliability-lab-control-plane` |
| Container image | `busybox:1.36` |
| Workload type | Simulated AI inference service |
| GPU usage | None |

## 3. Incident A: Readiness Probe Failure

### Symptoms

The `readiness-failure` Pod started successfully but remained unready.

Initial observations:

- Pod phase: `Running`
- Ready containers: `0/1`
- Container restarts: `0`
- Pod condition: `Ready=False`

The container process was running, but Kubernetes did not consider it ready to receive Service traffic.

### Failure Evidence

The kubelet reported:

```text
Readiness probe failed:
cat: can't open '/tmp/model-ready':
No such file or directory
```

Repeated failures were recorded in Kubernetes events.

### Root Cause

The application created `/tmp/service-started`, while the readiness probe checked `/tmp/model-ready`.

Because the expected file was missing, the readiness check failed.

This simulated an inference application whose process had started but whose model was not yet ready.

### Manual Recovery

The missing readiness file was created inside the running container:

```bash
kubectl exec readiness-failure -- \
  sh -c 'echo "Model loaded successfully" > /tmp/model-ready'
```

Kubernetes subsequently reported:

```text
pod/readiness-failure condition met
```

The Pod became `1/1 Running` with zero restarts at the time of recovery.

### Corrected Workload

A separate Pod, `readiness-fixed`, was deployed.

Its startup sequence:

1. Started the simulated inference service.
2. Waited 10 seconds to simulate model loading.
3. Created `/tmp/model-ready`.
4. Continued running.

The readiness probe initially failed during startup, then succeeded after the file became available.

### Recovery Verification

The corrected workload reached:

- `Status=Running`
- `Ready=True`
- `PodScheduled=True`
- Zero restarts during the initial verification

Application logs:

```text
Starting simulated AI inference service
Loading simulated model...
Inference service is ready
```

### Later Observation

During extended testing, both readiness Pods showed three restarts.

The original `readiness-failure` Pod was again `0/1 Running`, while `readiness-fixed` was `1/1 Running`.

Both manifests used a `sleep 3600` command with `restartPolicy: Always`. This provides a possible explanation for restarts during extended operation, but the exact cause of each restart was not independently confirmed.

The manually created readiness file was not a durable configuration fix because container recreation does not preserve that file.

## 4. Incident B: Liveness Probe Failure

### Symptoms

The `liveness-failure` Pod initially started normally but repeatedly failed its liveness probe.

The workload checked:

```text
/tmp/service-healthy
```

The application did not create this file.

### Failure Evidence

The kubelet reported:

```text
Liveness probe failed:
cat: can't open '/tmp/service-healthy':
No such file or directory
```

A subsequent event confirmed:

```text
Container inference failed liveness probe,
will be restarted
```

The first observed restart had:

- Restart count: 1
- Previous container exit code: 137
- Previous container state: Terminated

Exit code 137 indicates SIGKILL termination, but does not independently establish an out-of-memory failure. The kubelet event identifies the failed liveness probe as the restart trigger in this case.

### Extended Observation

After several hours, the original workload showed:

```text
STATUS: CrashLoopBackOff
RESTARTS: 67
```

This demonstrated the consequences of repeatedly failing liveness checks.

### Root Cause

The configured liveness probe checked for a health file that the application never created.

Kubernetes therefore treated the running container as unhealthy and restarted it after the configured failure threshold.

### Remediation

A separate corrected Pod, `liveness-fixed`, was deployed.

The application created `/tmp/service-healthy` during startup, before the first scheduled liveness check.

The liveness probe then successfully checked the file.

### Recovery Verification

The corrected workload reported:

- `Status=Running`
- `Ready=True`
- Zero restarts after more than two minutes
- No unhealthy probe events in the captured Pod description

Application logs:

```text
Starting simulated AI inference service
Initializing application health state
Application health check is ready
```

The successful result demonstrates that the configured health condition can be satisfied without repeated restarts.

## 5. Readiness vs. Liveness

| Mechanism | Readiness Probe | Liveness Probe |
|---|---|---|
| Purpose | Determine whether a container is ready for traffic | Determine whether a container should be restarted |
| Failure consequence | Container becomes NotReady | Container is restarted after the failure threshold |
| Directly triggers restart | No | Yes |
| Example AI scenario | Model weights still loading | Inference process stuck or unhealthy |
| Operational concern | Reduced serving capacity | Repeated restarts and possible CrashLoopBackOff |

A Pod without a readiness probe may report Ready even when its application is not actually functioning correctly.

## 6. Production Troubleshooting Procedure

When investigating probe failures:

1. Check Pod readiness, status, and restart count.
2. Inspect `kubectl describe pod` for probe configuration and events.
3. Compare the probe's target with actual application behavior.
4. Inspect current and previous container logs.
5. Review container termination reasons and exit codes.
6. Check whether startup or model loading takes longer than probe thresholds allow.
7. Validate the health endpoint or command inside the container.
8. Apply a corrected probe or application configuration.
9. Verify readiness, liveness, restart stability, and application behavior.
10. Monitor the workload after recovery.

## 7. Customer Communication Simulation

### Initial Update

We identified a workload health-check issue affecting the simulated inference service. The container process starts, but Kubernetes reports failed health probes. We are investigating whether the configured checks accurately reflect application readiness and health.

### Investigation Update

The readiness issue was traced to a missing model-ready indicator. Separately, the liveness configuration repeatedly checked for a nonexistent health file, causing container restarts. We have reproduced both conditions and are validating corrected configurations.

### Resolution Update

Corrected test workloads successfully demonstrated readiness recovery and stable liveness checks. The readiness workload became available after simulated model initialization, while the corrected liveness workload remained running without restarts during verification. We recommend aligning probe behavior with actual application startup and health conditions.

## 8. Prevention and Operational Recommendations

- Design readiness checks around actual serving capability.
- Design liveness checks around conditions that justify restarting the process.
- Use startup probes for applications with long initialization times.
- Allow sufficient time for AI model loading.
- Avoid overly aggressive probe thresholds.
- Monitor restart counts and `CrashLoopBackOff` conditions.
- Capture kubelet events and previous container logs.
- Distinguish liveness-triggered restarts from OOMKilled events.
- Test health probes before production deployment.
- Use long-running application processes rather than short-lived simulation commands for sustained reliability testing.

## 9. Lab Manifests

- [Readiness failure](../../kubernetes/workloads/lab-007/readiness-failure.yaml)
- [Corrected readiness](../../kubernetes/workloads/lab-007/readiness-fixed.yaml)
- [Liveness failure](../../kubernetes/workloads/lab-007/liveness-failure.yaml)
- [Corrected liveness](../../kubernetes/workloads/lab-007/liveness-fixed.yaml)

## 10. Key Lessons

A running container is not necessarily ready to serve traffic.

Readiness probe failures mark a container unready without directly restarting it.

Liveness probe failures can cause repeated container restarts and eventually `CrashLoopBackOff`.

Health probes must reflect meaningful application conditions, especially for AI inference systems that require significant startup time.

This lab used CPU-only BusyBox workloads to simulate health-check behavior. No real model inference or GPU processing was performed.
