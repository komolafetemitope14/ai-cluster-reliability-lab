
# LAB-012 — Python Diagnostic Automation

## Overview

LAB-012 implements a lightweight Python command-line tool for read-only infrastructure diagnostics.

The tool checks three components of the local AI infrastructure reliability lab:

- Kubernetes node readiness.
- Slurm services and compute-node availability.
- Prometheus readiness and alert-rule health.

It produces a structured JSON report and returns a nonzero exit code when a diagnostic check identifies an error or warning.

This lab builds on the Kubernetes, Slurm, and monitoring environments established in LAB-001 through LAB-011.

## Objectives

1. Build a reusable Python infrastructure diagnostic tool.
2. Collect health information from multiple infrastructure systems.
3. Interpret diagnostic output using consistent status categories.
4. Generate machine-readable JSON evidence.
5. Validate healthy and unhealthy conditions.
6. Test failure handling without disrupting running infrastructure.
7. Document operational limitations and reproducible procedures.

## Environment

| Component | Configuration |
|---|---|
| Workstation | Lenovo ThinkPad T480 |
| Operating system | Ubuntu Linux |
| Python | 3.14.4 |
| Kubernetes | kind, Kubernetes v1.34.0 |
| Kubernetes context | `kind-ai-reliability-lab` |
| Slurm | 25.11.2 |
| Slurm cluster | `ai-reliability-slurm` |
| Prometheus | 3.5.0 |
| Grafana | 12.1.0 |
| GPU | None; CPU-only lab |

The tool uses Python's standard library and existing system commands. No additional Python packages or infrastructure services were installed.

## Repository Files

```text
scripts/python/lab-012/
└── diagnose.py

tests/lab-012/
└── test_diagnose.py

labs/LAB-012-python-diagnostic-automation/
├── README.md
└── evidence/
    ├── 01-baseline-report.json
    ├── 02-automated-tests.txt
    └── 03-controlled-failure.json
```

## Architecture

```text
                  Python Diagnostic CLI
                         diagnose.py
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
         Kubernetes         Slurm          Prometheus
             |                |                |
       kubectl commands   systemctl/sinfo    HTTP API
             |                |                |
             +----------------+----------------+
                              |
                              v
                       Health Evaluation
                              |
                              v
                      JSON Diagnostic Report
                              |
                              v
                        Process Exit Code
```

The tool performs read-only checks. It does not modify Kubernetes workloads, Slurm configuration, or Prometheus alert rules.

## Diagnostic Checks

### Kubernetes

The Kubernetes check:

1. Retrieves the active Kubernetes context.
2. Queries Kubernetes nodes using `kubectl get nodes -o json`.
3. Inspects each node's `Ready` condition.
4. Reports whether all discovered nodes are Ready.

Observed baseline:

```text
Context: kind-ai-reliability-lab
Node: ai-reliability-lab-control-plane
Ready: true
Status: OK
```

The check reports a warning when a node is NotReady or when no nodes are returned.

Command execution failures are reported as errors.

### Slurm

The Slurm check:

1. Inspects `munge`, `slurmctld`, and `slurmd` service status.
2. Retrieves node information using `sinfo`.
3. Evaluates node states against a basic list of unhealthy state prefixes.
4. Reports a warning when a service is inactive or a node appears unhealthy.

Observed baseline:

```text
munge: active
slurmctld: active
slurmd: active

Node: enianyole-ThinkPad-T480
State: idle

Status: OK
```

This is a basic health assessment, not a complete interpretation of all Slurm state flags and scheduler conditions.

### Prometheus

The Prometheus check:

1. Requests the `/-/ready` endpoint.
2. Retrieves alert-rule information from `/api/v1/rules`.
3. Inspects alert states and rule health.
4. Reports firing alerts and unhealthy rules.

Observed baseline:

```text
Prometheus readiness: true
Alert rules: 2

PrometheusTargetDown:
  State: inactive
  Health: ok

Lab011SyntheticFailure:
  State: inactive
  Health: ok

Status: OK
```

The tool checks Prometheus alert rules but does not validate Alertmanager notification delivery.

## Usage

### Start the Prometheus port-forward

The monitoring stack runs in the existing kind cluster.

If a port-forward is not already active:

```bash
kubectl port-forward -n monitoring svc/prometheus 9091:9090
```

Do not start another port-forward when port `9091` is already in use by the existing one.

### Display CLI help

From the repository root:

```bash
python3 scripts/python/lab-012/diagnose.py --help
```

### Run infrastructure diagnostics

```bash
python3 scripts/python/lab-012/diagnose.py \
  --prometheus-url http://127.0.0.1:9091
```

### Save a JSON report

```bash
python3 scripts/python/lab-012/diagnose.py \
  --prometheus-url http://127.0.0.1:9091 \
  --output labs/LAB-012-python-diagnostic-automation/evidence/01-baseline-report.json
```

The report includes:

- Lab identifier.
- UTC timestamp.
- Overall diagnostic status.
- Component-specific status and message.
- Relevant diagnostic details.

## Status Interpretation

| Status | Meaning |
|---|---|
| `OK` | All conditions evaluated by the check are healthy |
| `WARNING` | A condition requires investigation |
| `ERROR` | A diagnostic operation failed or a required endpoint was unavailable |

Overall status follows the most severe component result:

```text
ERROR > WARNING > OK
```

The current implementation returns:

- Exit code `0` when overall status is `OK`.
- Exit code `1` when overall status is `WARNING` or `ERROR`.

## Experiment 1 — Healthy Infrastructure Baseline

### Procedure

The diagnostic tool was executed against the existing Kubernetes, Slurm, and Prometheus environments.

### Observed Results

| Component | Status | Evidence |
|---|---|---|
| Kubernetes | OK | Control-plane node Ready |
| Slurm | OK | Services active; node idle |
| Prometheus | OK | Ready; two alert rules inactive and healthy |
| Overall | OK | All three checks passed |

The report was saved to:

`evidence/01-baseline-report.json`

This establishes a healthy reference state for later comparisons.

## Experiment 2 — Automated Failure Tests

The Python standard-library `unittest` framework was used to test diagnostic behavior with mocked command output and HTTP responses.

### Test Coverage

| Test | Expected Result |
|---|---|
| Healthy Kubernetes node | OK |
| Kubernetes node NotReady | WARNING |
| Kubernetes command failure | ERROR |
| Healthy Slurm services and node | OK |
| Inactive Slurm service | WARNING |
| Down Slurm node | WARNING |
| Healthy Prometheus alert rules | OK |
| Firing Prometheus alert | WARNING |
| Unreachable Prometheus endpoint | ERROR |

### Execute Tests

```bash
python3 -m unittest discover \
  -s tests/lab-012 \
  -p 'test_*.py' \
  -v
```

### Observed Result

```text
Ran 9 tests

OK
```

All nine tests passed.

The test suite does not require intentionally stopping infrastructure services or changing live alert rules.

Test evidence:

`evidence/02-automated-tests.txt`

## Experiment 3 — Controlled Prometheus Connectivity Failure

### Objective

Verify that the diagnostic tool identifies an unreachable monitoring endpoint and returns a nonzero exit code.

### Procedure

The tool was pointed at an unused local port rather than the working Prometheus port-forward.

```bash
python3 scripts/python/lab-012/diagnose.py \
  --prometheus-url http://127.0.0.1:19091 \
  --output labs/LAB-012-python-diagnostic-automation/evidence/03-controlled-failure.json
```

### Observed Results

```text
Kubernetes: OK
Slurm: OK
Prometheus: ERROR

Overall status: ERROR
Diagnostic exit code: 1
```

The Prometheus check reported a connection-refused error.

The tool correctly returned exit code `1`.

### Interpretation

This experiment demonstrates detection of a deliberately unreachable local endpoint.

It does not demonstrate a real Prometheus service outage, because the running monitoring service was not stopped or modified.

Evidence:

`evidence/03-controlled-failure.json`

## Evidence

| File | Description |
|---|---|
| `01-baseline-report.json` | Successful live diagnostic report |
| `02-automated-tests.txt` | Output from nine passing unit tests |
| `03-controlled-failure.json` | JSON report showing simulated monitoring connectivity failure |

The evidence files contain operational information from the local learning environment. They should be reviewed before publication.

## Operational Safety

The diagnostic tool does not:

- Restart Kubernetes or Slurm services.
- Delete or modify Kubernetes resources.
- Submit or cancel Slurm jobs.
- Modify Prometheus rules.
- Restart monitoring pods.
- Require administrative credentials in source code.

The controlled connectivity test used an unused local port, preserving the running Prometheus service.

## Limitations

1. The tool currently assumes the required system commands are available on the machine where it runs.
2. Kubernetes coverage focuses on node readiness rather than full workload health.
3. Slurm node-state interpretation is intentionally basic and does not cover every possible state or flag.
4. Prometheus is accessed through a local port-forward in this environment.
5. The Prometheus check inspects alert-rule state but does not verify notification delivery.
6. The current tool does not retry transient failures.
7. JSON reports may contain hostnames, Kubernetes context names, and diagnostic error messages.
8. Automated failure tests use mocks; they do not prove every failure mode in a production cluster.
9. The environment is CPU-only and does not demonstrate real GPU hardware diagnostics.

## Lessons Learned

- Python's standard library can support useful cross-platform diagnostic automation without additional packages.
- Structured JSON output makes infrastructure checks easier to archive, inspect, and process.
- Consistent status categories help distinguish healthy conditions from warnings and errors.
- Exit codes allow diagnostic tools to integrate with scripts and automated workflows.
- Mocked tests provide safe failure coverage without disrupting running infrastructure.
- A successful diagnostic baseline is useful for evaluating later failure scenarios.
- Clear limitations prevent a local learning experiment from being mistaken for production-grade monitoring.

## Outcome

LAB-012 successfully implemented a read-only Python infrastructure diagnostic tool covering Kubernetes, Slurm, and Prometheus.

The tool produced a healthy baseline report, passed nine automated tests, and correctly detected a controlled monitoring connectivity failure with exit code `1`.

The implementation and evidence demonstrate reusable diagnostic automation suitable for further development.

## Next Lab

**LAB-013 — Bash Health Checks and Evidence Collection**

LAB-013 will build on these diagnostics by automating health checks, evidence collection, and incident-oriented reporting.
