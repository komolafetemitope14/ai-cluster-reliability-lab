# LAB-014 — Customer Incident Communication and Root Cause Analysis

## Overview

This lab demonstrates customer-facing incident communication, structured incident investigation, root cause analysis (RCA), and corrective and preventive action planning for AI infrastructure reliability.

The lab uses a simulated monitoring connectivity incident informed by the controlled failure-detection exercises completed in LAB-013.

The objective is to demonstrate how a Customer Reliability Engineer can communicate clearly during an incident while distinguishing confirmed technical facts, working hypotheses, customer impact, and recovery status.

**Lab status:** In progress

**Environment:** Local Ubuntu workstation with kind Kubernetes, Slurm, Prometheus, and Bash diagnostic automation.

**Scenario type:** Simulated customer incident, not a real production outage.

---

## Learning Objectives

By completing this lab, the operator will demonstrate the ability to:

1. Identify and classify an infrastructure reliability incident.
2. Communicate customer impact without overstating unverified facts.
3. Produce initial, ongoing, and resolution customer updates.
4. Maintain a timestamped incident investigation timeline.
5. Distinguish symptoms, contributing factors, and root cause.
6. Document technical evidence and investigation limitations.
7. Develop corrective and preventive actions.
8. Produce a professional, blameless RCA.
9. Validate that customer communications align with technical evidence.

---

## Incident Scenario

### Scenario Identifier

**LAB-014-SIM-001**

### Incident Title

Simulated Prometheus Monitoring Endpoint Connectivity Failure

### Scenario Description

A hypothetical customer reports that infrastructure monitoring information is unavailable or delayed.

The reliability engineer investigates whether the monitoring endpoint is reachable and whether the underlying Kubernetes and Slurm infrastructure remains healthy.

The investigation uses diagnostic techniques and evidence from LAB-013, including:

- Kubernetes context and node readiness checks.
- MUNGE and Slurm service health checks.
- Slurm node state inspection.
- Prometheus readiness checks.
- Automated incident evidence collection.
- Controlled failure-detection tests.

### Simulated Customer Impact

For this exercise, the customer is assumed to experience reduced visibility into infrastructure monitoring.

This is a hypothetical impact statement used for communication practice.

It does not establish that any real customer lost monitoring access or that production workloads were disrupted.

### Observed Technical Basis

LAB-013 demonstrated that:

- The healthy infrastructure checks completed successfully.
- The evidence collector captured 13 successful checks during the healthy run.
- A deliberately unreachable Prometheus URL caused the health-check script to return exit code 1.
- The controlled-failure evidence collection recorded 9 successful captures and 4 warnings.
- The automation identified Prometheus connectivity as the failing component.
- Seven automated tests passed.

The controlled failure used a deliberately unreachable local endpoint. It did not demonstrate an actual Prometheus service outage.

---

## Scope and Safety

This lab focuses on incident communication and documentation.

The exercise will not require stopping Prometheus, restarting Kubernetes, interrupting Slurm, or changing production-like infrastructure configuration.

Existing services will be preserved.

All customer communications will be clearly labeled as simulated.

Private diagnostic archives, authentication secrets, and sensitive infrastructure details must not be committed to GitHub.

---

## Planned Deliverables

### 1. Customer Incident Communications

A sequence of simulated customer-facing messages covering:

- Initial acknowledgment.
- Investigation progress.
- Mitigation or recovery update.
- Incident resolution and follow-up.

Each message should communicate known impact, current status, next steps, and uncertainty appropriately.

### 2. Internal Incident Timeline

A chronological record of the simulated incident, including:

- Detection.
- Triage.
- Evidence review.
- Working hypotheses.
- Diagnosis.
- Recovery validation.
- Customer notification.

The timeline must distinguish scenario-assumed events from observations actually supported by LAB-013 evidence.

### 3. Root Cause Analysis

A structured RCA documenting:

- Incident summary.
- Customer impact.
- Detection and investigation.
- Technical findings.
- Root cause and contributing factors.
- Recovery and validation.
- Corrective and preventive actions.
- Evidence limitations.
- Lessons learned.

Any scenario-assumed root cause must be identified as hypothetical rather than independently proven.

### 4. Evidence and Validation

Supporting evidence will reference relevant LAB-013 summaries and any additional read-only checks performed during LAB-014.

The final review will verify consistency between technical evidence, customer communications, and the RCA.

---

## Investigation Methodology

The incident workflow follows eight stages:

1. **Detect:** Identify the reported monitoring symptom.
2. **Acknowledge:** Confirm investigation is underway.
3. **Scope:** Establish which services and customers are potentially affected.
4. **Collect:** Review infrastructure and monitoring health evidence.
5. **Diagnose:** Separate endpoint reachability problems from underlying workload failures.
6. **Communicate:** Provide accurate and timely status updates.
7. **Validate:** Confirm the available evidence supports the resolution statement.
8. **Review:** Produce a blameless RCA and track follow-up actions.

---

## Evidence Sources

The primary technical reference is LAB-013:

[LAB-013 — Bash Health Checks and Evidence Collection](../LAB-013-bash-health-checks-and-evidence-collection/README.md)

Relevant published evidence includes:

- [Healthy collection summary](../LAB-013-bash-health-checks-and-evidence-collection/evidence/01-healthy-collection-summary.txt)
- [Controlled failure summary](../LAB-013-bash-health-checks-and-evidence-collection/evidence/02-controlled-failure-summary.txt)
- [Automated test results](../LAB-013-bash-health-checks-and-evidence-collection/evidence/03-automated-tests.txt)

The evidence supports detection behavior and local infrastructure observations. It does not independently establish real customer impact or production root cause.

---

## Success Criteria

LAB-014 will be considered complete when:

- The simulated customer communications are documented.
- The internal incident timeline is complete.
- A structured RCA has been written.
- Technical observations are distinguished from scenario assumptions.
- Corrective and preventive actions are specific and testable.
- All documentation has been reviewed for accuracy and sensitive information.
- Git whitespace and repository checks pass.
- The completed lab is committed and published to GitHub.

---

## Current Status

**In progress:** Initial lab documentation created.

**Next activity:** Draft simulated customer incident communications, followed by the internal timeline and root cause analysis.

---

## Skills Demonstrated

- Customer-facing incident communication.
- AI infrastructure reliability investigation.
- Monitoring connectivity troubleshooting.
- Evidence-based incident documentation.
- Root cause analysis.
- Blameless post-incident review.
- Corrective and preventive action planning.
- Technical-to-nontechnical communication.
