# LAB-004: Kubernetes Service Connectivity Failure

**Status:** Resolved

**Date:** November 18, 2026

**Environment:** Kubernetes v1.34.0, kind, Ubuntu Linux

**Incident type:** Kubernetes Service selector misconfiguration

**Severity:** Training simulation — no production customer impact

## 1. Incident Summary

A simulated AI inference HTTP service was running successfully inside Kubernetes but could not be reached through its Kubernetes ClusterIP Service.

DNS resolution succeeded, but HTTP requests returned a connection-refused error.

Investigation revealed that the Kubernetes Service selector did not match the labels assigned to the inference Pod. Consequently, the Service had no backend endpoints.

Correcting the selector restored connectivity.

## 2. Customer Impact

In a production AI inference environment, this type of configuration error could prevent applications from reaching inference endpoints, causing failed requests and service unavailability.

This incident was reproduced in a local Kubernetes training cluster. No real AI model or production customer was involved.

## 3. Environment

- Kubernetes version: v1.34.0
- Cluster: `ai-reliability-lab`
- Namespace: `default`
- Deployment: `inference-server`
- Service: `inference-service`
- Service type: `ClusterIP`
- Service ClusterIP: `10.96.31.168`
- Service port: `80`
- Container port: `8080`
- Application image: `python:3.12-alpine`
- Diagnostic client: `busybox:1.36`

## 4. Symptoms

The inference Deployment successfully rolled out with one available replica.

The inference Pod was running with zero restarts, and its logs confirmed that Python's HTTP server was listening on port 8080.

However, an HTTP request from another Pod failed:

```text
Connecting to inference-service.default.svc.cluster.local (10.96.31.168:80)
wget: can't connect to remote host (10.96.31.168): Connection refused
command terminated with exit code 1
```

The Kubernetes Service existed but reported no backend endpoints.

## 5. Investigation

### Step 1: Verify application health

Commands:

```bash
kubectl get deployments
kubectl get pods -l app=inference-server -o wide
kubectl logs deployment/inference-server
```

The Deployment had one ready replica, and the application logs confirmed:

```text
Serving HTTP on 0.0.0.0 port 8080 ...
```

### Step 2: Inspect the Service

Commands:

```bash
kubectl get services
kubectl describe service inference-service
```

The Service had a ClusterIP and exposed port 80, forwarding to target port 8080.

However, its selector was:

```yaml
selector:
  app: inference-backend
```

### Step 3: Inspect Pod labels and endpoints

Commands:

```bash
kubectl get pods --show-labels
kubectl get endpointslices -l kubernetes.io/service-name=inference-service
```

The inference Pod had the label:

```text
app=inference-server
```

The Service had no endpoints because its selector did not match the Pod label.

### Step 4: Test DNS resolution

A diagnostic BusyBox Pod was created:

```bash
kubectl run dns-client \
  --image=busybox:1.36 \
  --restart=Never \
  --command -- sleep 3600
```

DNS resolution was tested using:

```bash
kubectl exec dns-client -- nslookup inference-service.default.svc.cluster.local
```

The lookup succeeded:

```text
Name: inference-service.default.svc.cluster.local
Address: 10.96.31.168
```

This established that DNS resolution was functioning. The connectivity problem was associated with missing Service backends rather than an inability to resolve the Service name.

## 6. Root Cause

The Kubernetes Service selector was incorrectly configured as:

```yaml
selector:
  app: inference-backend
```

The inference Pod was labeled:

```yaml
app: inference-server
```

Because these values did not match, Kubernetes did not associate the running Pod with the Service.

The Service consequently had no backend endpoints, and HTTP requests through its ClusterIP failed.

## 7. Remediation

A corrected Service manifest was created with the selector:

```yaml
selector:
  app: inference-server
```

The corrected configuration was applied using:

```bash
kubectl apply -f kubernetes/workloads/lab-004/inference-service-fixed.yaml
```

Kubernetes then associated the running inference Pod with the Service.

## 8. Recovery Verification

The corrected Service reported:

```text
Selector:  app=inference-server
Endpoints: 10.244.0.10:8080
```

The EndpointSlice also listed the Pod IP and port 8080.

The HTTP request was repeated:

```bash
kubectl exec dns-client -- wget -T 5 -O - http://inference-service.default.svc.cluster.local
```

This time, the client successfully retrieved an HTML directory listing from the Python HTTP server.

The successful response verified that traffic could reach the application through the Kubernetes Service.

## 9. Preventive Measures

- Validate Service selectors against Deployment Pod labels before deployment.
- Check EndpointSlices when a Service exists but clients cannot connect.
- Test DNS resolution separately from HTTP or TCP connectivity.
- Include service connectivity checks in deployment validation.
- Use consistent labels across Kubernetes manifests.
- Add automated smoke tests to detect missing Service backends.

## 10. Example Customer Communication

**Initial update:**

We have confirmed that the inference application is running, but requests through its Kubernetes Service are failing. DNS resolution is successful, and we are investigating the Service's backend configuration.

**Resolution update:**

We identified a mismatch between the Kubernetes Service selector and the inference Pod labels. After correcting the selector, Kubernetes registered the expected backend endpoint, and HTTP connectivity was successfully verified.

## 11. Reproduction Files

- `../../kubernetes/workloads/lab-004/inference-server.yaml`
- `../../kubernetes/workloads/lab-004/inference-service-broken.yaml`
- `../../kubernetes/workloads/lab-004/inference-service-fixed.yaml`

## 12. Lessons Learned

A running Kubernetes Pod does not guarantee that applications can reach it through a Service.

DNS resolution can succeed even when a Service has no backend endpoints.

Checking Service selectors, Pod labels, and EndpointSlices is essential when investigating Kubernetes connectivity incidents.
