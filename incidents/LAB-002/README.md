# LAB-002: AI Inference Service CrashLoopBackOff

**Status:** Resolved  
**Date:** November 18, 2026  
**Environment:** Local Kubernetes v1.34.0 cluster using kind  
**Incident type:** Container startup failure / CrashLoopBackOff  
**Severity:** Training exercise — no production customer impact

## 1. Incident Summary

A simulated AI inference service repeatedly failed after its container started, leaving the Kubernetes Deployment unavailable.

The failure was intentionally introduced using a startup script that printed a configuration error and exited with status code 1.

The incident demonstrates troubleshooting a Kubernetes CrashLoopBackOff, examining container termination details, retrieving previous container logs, and verifying recovery.

## 2. Customer Impact

In a production environment, a similar failure could prevent an AI inference service from accepting requests, resulting in failed or delayed customer inference operations.

This exercise used a BusyBox container rather than a real AI model server. No production customers were affected.

## 3. Symptoms

The affected workload was named `inference-crashloop`.

Observed pod status:

```text
READY   STATUS             RESTARTS
0/1     CrashLoopBackOff   5
```

The Deployment reported one desired replica and zero available replicas.

The container repeatedly started and terminated.

## 4. Investigation

Commands used:

```bash
kubectl get pods -l app=inference-crashloop
kubectl describe deployment inference-crashloop
kubectl describe pod inference-crashloop-74555d7786-2vgq5
kubectl logs inference-crashloop-74555d7786-2vgq5 -c inference --previous
kubectl get events --sort-by=.metadata.creationTimestamp
```

The pod description showed:

```text
State:          Waiting
Reason:         CrashLoopBackOff

Last State:     Terminated
Reason:         Error
Exit Code:      1

Restart Count:  5
```

Kubernetes events confirmed successful scheduling and repeated container starts, followed by restart backoff warnings.

Previous container logs showed:

```text
Starting simulated AI inference service...
ERROR: MODEL_PATH environment variable is missing
```

## 5. Root Cause

The original workload contained a startup script that deliberately printed an error and exited with code 1.

The script did not actually check whether `MODEL_PATH` existed; the error was simulated.

Because the Deployment's container restart policy is effectively `Always`, Kubernetes repeatedly attempted to restart the failed container.

The resulting repeated failures caused the `CrashLoopBackOff` condition.

## 6. Remediation

A separate corrected Deployment, `inference-fixed`, was created to preserve the original failure scenario.

The corrected workload defined the `MODEL_PATH` environment variable:

```yaml
env:
  - name: MODEL_PATH
    value: "/models/demo-model"
```

Its startup script validated that the variable was nonempty:

```sh
if [ -z "$MODEL_PATH" ]; then
  echo "ERROR: MODEL_PATH environment variable is missing"
  exit 1
fi
```

When the variable was configured, the simulated service continued running instead of immediately exiting.

The demonstration path does not point to a verified AI model. No real inference requests were processed.

## 7. Recovery Verification

The corrected Deployment was created successfully.

Pod status:

```text
READY   STATUS    RESTARTS
1/1     Running   0
```

Rollout verification:

```text
deployment "inference-fixed" successfully rolled out
```

Application logs:

```text
Starting simulated AI inference service...
MODEL_PATH configured: /models/demo-model
Simulated AI inference service started successfully
```

The corrected workload was healthy at the time of verification.

## 8. Preventive Measures

1. Validate required configuration values during application startup.
2. Use Kubernetes ConfigMaps or Secrets for appropriate application configuration.
3. Monitor container restart counts and unavailable Deployment replicas.
4. Investigate `CrashLoopBackOff` using pod descriptions and previous container logs.
5. Use readiness and liveness probes where appropriate for real services.
6. Validate startup behavior in a test environment before production deployment.

## 9. Example Customer Communication

### Initial Update

We identified that the inference workload is being scheduled successfully, but its container repeatedly exits during startup. We are reviewing container termination details and application logs to isolate the startup failure.

### Resolution Update

The investigation identified a failing startup script in the simulated inference workload. We deployed a corrected configuration and verified that the replacement test workload started successfully with zero restarts. The Kubernetes Deployment rollout also completed successfully.

## 10. Reproduction Files

- `../../kubernetes/workloads/inference-crashloop.yaml` — intentionally failing Deployment
- `../../kubernetes/workloads/inference-fixed.yaml` — corrected Deployment

## 11. Lessons Learned

A healthy Kubernetes node and successful pod scheduling do not guarantee application availability.

`kubectl describe pod` identifies termination reasons and restart behavior, while `kubectl logs --previous` can reveal errors from an earlier failed container instance.

The combination of Kubernetes events, exit codes, application logs, and rollout verification provides a reliable foundation for investigating container startup incidents.
