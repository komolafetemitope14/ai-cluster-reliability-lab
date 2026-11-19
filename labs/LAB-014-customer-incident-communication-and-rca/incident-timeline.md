# LAB-014 — Internal Incident Timeline

## Incident Overview

**Incident ID:** LAB-014-SIM-001

**Incident title:** Simulated Prometheus Monitoring Endpoint Connectivity Failure

**Incident type:** Monitoring connectivity investigation

**Environment:** Local Ubuntu workstation, kind Kubernetes, Slurm, and Prometheus

**Customer:** Fictional AI infrastructure customer

**Classification:** Training simulation — not a production incident

**Timeline window:** 10:00–10:45 UTC (illustrative)

**Scenario status:** Resolved within the simulation

---

## Purpose

This document records the investigation and communication sequence for a hypothetical monitoring connectivity incident.

The timeline is based on a fictional customer scenario informed by the controlled diagnostic exercises completed in LAB-013.

The timestamps below are illustrative. They are not actual timestamps extracted from monitoring logs or incident records.

No real customer outage, production infrastructure failure, or service restoration is claimed.

---

## Incident Timeline

| Time (UTC) | Event | Action or Finding | Evidence Classification |
|---|---|---|---|
| 10:00 | Customer report received | A fictional customer reports that monitoring information is unavailable. | Simulated event |
| 10:00 | Incident acknowledged | Initial customer communication confirms that investigation is underway. | Simulated communication |
| 10:05 | Investigation initiated | Engineer reviews monitoring endpoint reachability and plans infrastructure health checks. | Simulated investigation |
| 10:10 | Diagnostic evidence reviewed | LAB-013 healthy-run results show successful infrastructure checks. | Supported by LAB-013 evidence |
| 10:12 | Monitoring connectivity failure reviewed | LAB-013 controlled test shows that an intentionally unreachable endpoint produces a failed Prometheus connectivity check. | Supported by LAB-013 evidence |
| 10:15 | Investigation update issued | Customer is informed that monitoring connectivity is being investigated and compute disruption is unconfirmed. | Simulated communication |
| 10:20 | Failure scope assessed | Available test evidence supports an endpoint reachability failure, not a demonstrated Kubernetes or Slurm outage. | Evidence-based interpretation |
| 10:25 | Recovery approach reviewed | Engineer confirms that checking the intended endpoint configuration is appropriate for this scenario. | Simulated investigation |
| 10:30 | Recovery update issued | Customer is informed that endpoint configuration and connectivity are being validated. | Simulated communication |
| 10:35 | Healthy baseline compared | LAB-013 healthy checks are compared with controlled-failure results to explain the diagnostic difference. | Supported by LAB-013 evidence |
| 10:40 | Closure decision | The hypothetical incident is considered resolved after the scenario's endpoint validation step. | Simulated event |
| 10:45 | Final resolution issued | Customer receives a simulated resolution message and follow-up commitments. | Simulated communication |

---

## Detection

### Simulated Trigger

A fictional customer reports that monitoring information cannot be accessed.

The report is treated as a potential monitoring visibility incident.

### Technical Basis

LAB-013 demonstrated that Bash diagnostic automation can detect an unreachable Prometheus endpoint.

The controlled test used a deliberately unreachable local endpoint.

This establishes that the diagnostic check detects connectivity failure. It does not establish that a real monitoring outage occurred.

---

## Initial Triage

The investigation distinguishes three potential failure categories:

1. Monitoring endpoint connectivity or incorrect endpoint configuration.
2. Prometheus service availability.
3. Underlying Kubernetes or Slurm infrastructure health.

The available LAB-013 evidence supports the first category within the controlled test.

It does not independently establish a production Prometheus service failure or compute workload disruption.

---

## Evidence Review

### Healthy Baseline

LAB-013 recorded a healthy evidence-collection run with 13 successful checks.

The healthy results provide a comparison point for the controlled failure.

### Controlled Failure

The deliberately unreachable Prometheus endpoint caused the Bash health-check script to return a nonzero exit status.

The controlled-failure collection recorded nine successful captures and four warnings.

The automation identified monitoring connectivity as the relevant failure condition.

### Automated Validation

Seven automated tests passed.

These tests validate the implemented diagnostic behavior, not the occurrence of a real customer incident.

---

## Working Hypothesis

**Hypothesis:** The fictional monitoring access issue is caused by an incorrect or unreachable monitoring endpoint.

**Supporting observation:** The controlled LAB-013 test demonstrated that an unreachable endpoint causes a monitoring connectivity check to fail.

**Limitation:** The evidence does not establish why a real customer's monitoring endpoint would be unreachable.

The hypothesis is used to construct the training scenario. It must not be presented as a confirmed production root cause.

---

## Simulated Recovery and Validation

The scenario assumes that the engineer verifies the intended monitoring endpoint configuration and confirms the expected healthy behavior.

The underlying technical reference is the comparison between LAB-013's healthy-run results and deliberately failed connectivity test.

No production service restart, infrastructure repair, or real customer recovery occurred during this documentation exercise.

---

## Customer Communication Timeline

| Simulated Time (UTC) | Communication | Purpose |
|---|---|---|
| 10:00 | Initial acknowledgment | Confirm investigation and communicate uncertainty. |
| 10:15 | Investigation update | Explain findings and avoid unsupported impact claims. |
| 10:30 | Recovery update | Describe validation activities and expected next steps. |
| 10:45 | Final resolution | Close the fictional incident and identify follow-up actions. |

The complete messages are documented in [Customer Incident Communications](customer-communications.md).

---

## Investigation Limitations

- All incident timestamps are illustrative.
- Customer impact is hypothetical.
- No production monitoring outage was observed.
- The controlled test intentionally used an unreachable endpoint.
- No real customer communications were sent.
- The evidence does not prove that Kubernetes workloads or Slurm jobs were affected.
- The scenario's recovery and closure steps are simulated.

---

## Lessons for Customer Reliability Engineering

The exercise demonstrates the importance of:

- Recording a consistent investigation timeline.
- Separating customer reports from verified infrastructure observations.
- Establishing a healthy baseline before diagnosing failure.
- Distinguishing monitoring visibility from compute service availability.
- Communicating uncertainty rather than inventing conclusions.
- Validating resolution claims against available evidence.
- Maintaining a clear record for the subsequent root cause analysis.

---

## Outcome

**Deliverable:** Internal incident timeline for LAB-014-SIM-001.

**Status:** Drafted for LAB-014 review.

**Next activity:** Prepare the structured root cause analysis and corrective action plan.
