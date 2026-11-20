# LAB-015 — Simulated Customer Incident Update

**Scenario ID:** LAB-015-SIM-001  
**Subject:** Monitoring Connectivity Investigation — Findings and Validation  
**Date:** November 20, 2026  
**Audience:** Fictional AI infrastructure customer  
**Classification:** Training simulation — not an actual customer incident

---

## 1. Initial Customer Update

**Status: Investigating**

Hello,

Thank you for reporting difficulty accessing your expected monitoring information.

We are investigating the monitoring connectivity path and checking the underlying infrastructure separately to determine whether the issue affects monitoring visibility, compute availability, or both.

Our investigation includes checks of the Kubernetes environment, Slurm scheduling services, and Prometheus monitoring components.

At this stage, we have not established that compute workloads are affected.

We will distinguish confirmed findings from possible causes and provide an update after completing the diagnostic checks.

Thank you for your patience.

**AI Infrastructure Reliability Engineering Team**  
*Simulated customer communication*

---

## 2. Investigation Update

**Status: Monitoring connectivity issue reproduced in a controlled test**

Hello,

We have completed the initial infrastructure checks and reproduced a monitoring connectivity failure using a deliberately unreachable diagnostic endpoint.

The controlled test confirmed that our health-check automation can identify an unavailable monitoring endpoint.

During the same test, Kubernetes and Slurm health checks succeeded.

Our findings so far are:

- The Kubernetes control-plane node was Ready.
- The Slurm controller was responsive and its compute node was IDLE.
- Prometheus and Grafana deployments were available.
- The diagnostic script correctly reported the intentionally unreachable monitoring endpoint.

These results suggest that the reproduced failure is limited to the tested monitoring connection rather than indicating a general compute infrastructure outage.

We are completing direct Prometheus readiness validation before finalizing our assessment.

**AI Infrastructure Reliability Engineering Team**  
*Simulated customer communication*

---

## 3. Final Customer Update

**Status: Controlled test completed; service readiness validated**

Hello,

We have completed the monitoring connectivity investigation and validation checks.

### What we found

The monitoring failure reproduced during testing was caused by a deliberately unreachable endpoint supplied to the diagnostic health-check script.

The test produced the expected failure notification while the Kubernetes and Slurm checks continued to pass.

We subsequently tested the actual Prometheus server and received a successful readiness response.

### Infrastructure validation

| Component | Verified result |
|---|---|
| Prometheus | Server reported Ready |
| Kubernetes | Control-plane node Ready |
| Slurm | Controller UP |
| Monitoring diagnostic | Correctly detected the controlled unreachable endpoint |

### Impact assessment

We found no evidence of a Kubernetes node outage or Slurm controller failure during the recorded checks.

We also did not observe a real Prometheus service outage during validation.

Because this was a controlled training simulation, **no actual customer impact or production service interruption was established**.

### Resolution and next steps

No infrastructure restart, reconfiguration, or service recovery was required.

The controlled diagnostic test is complete, and the actual Prometheus readiness check succeeded.

For a comparable real-world issue, we recommend verifying the monitoring address and port used by the affected client, testing the customer's access path, and independently checking workload availability before concluding that compute services are affected.

### Final status

**Controlled monitoring connectivity test: Completed successfully.**

**Actual Prometheus readiness: Verified.**

**Kubernetes and Slurm health: Verified at the recorded check times.**

Thank you for your cooperation.

**AI Infrastructure Reliability Engineering Team**  
*Simulated customer communication*

---

## 4. Internal Communication Notes

This document demonstrates how reliability engineers can communicate technical investigations clearly while avoiding unsupported claims.

The initial update acknowledges the reported symptom without assuming its cause.

The investigation update separates monitoring connectivity from infrastructure availability.

The final update communicates the confirmed diagnostic cause, successful validation, and remaining limitations.

All customer messages are fictional examples. They were not sent to an actual customer.

## 5. Supporting Documentation

- [Incident report](incident-report.md)
- [Investigation runbook](investigation-runbook.md)
- [Controlled failure evidence](evidence/04-controlled-monitoring-failure.txt)
- [Validation evidence](evidence/05-validation-summary.txt)

**Communication principle:** Acknowledge the concern, report what the evidence proves, explain what remains uncertain, and communicate the next appropriate action.
