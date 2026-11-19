
#!/usr/bin/env python3
"""LAB-012: Read-only AI infrastructure diagnostic tool."""

import argparse
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import urlopen


def result(component, status, message, details=None):
    return {
        "component": component,
        "status": status,
        "message": message,
        "details": details or {},
    }


def run_command(command, timeout=15):
    """Execute a read-only command with a timeout."""
    if not shutil.which(command[0]):
        return None, f"Command not found: {command[0]}"

    try:
        completed = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except subprocess.TimeoutExpired:
        return None, f"Command timed out after {timeout}s"
    except OSError as exc:
        return None, str(exc)

    if completed.returncode != 0:
        error = completed.stderr.strip() or completed.stdout.strip()
        return None, error or f"Exit code {completed.returncode}"

    return completed.stdout.strip(), None


def check_kubernetes():
    context, error = run_command(
        ["kubectl", "config", "current-context"]
    )

    if error:
        return result("kubernetes", "ERROR", error)

    output, error = run_command(
        ["kubectl", "get", "nodes", "-o", "json"]
    )

    if error:
        return result(
            "kubernetes", "ERROR", error, {"context": context}
        )

    try:
        nodes = json.loads(output)["items"]
    except (ValueError, KeyError, TypeError) as exc:
        return result("kubernetes", "ERROR", str(exc))

    if not nodes:
        return result(
            "kubernetes", "WARNING", "No nodes found",
            {"context": context}
        )

    node_results = []

    for node in nodes:
        name = node["metadata"]["name"]
        conditions = node.get("status", {}).get("conditions", [])

        ready = any(
            condition.get("type") == "Ready"
            and condition.get("status") == "True"
            for condition in conditions
        )

        node_results.append({
            "name": name,
            "ready": ready,
        })

    all_ready = all(node["ready"] for node in node_results)

    return result(
        "kubernetes",
        "OK" if all_ready else "WARNING",
        "All Kubernetes nodes Ready"
        if all_ready else "One or more nodes NotReady",
        {"context": context, "nodes": node_results},
    )


def check_slurm():
    services = ["munge", "slurmctld", "slurmd"]
    service_states = {}

    for service in services:
        output, error = run_command(
            ["systemctl", "is-active", service]
        )
        service_states[service] = (
            output if not error else "inactive-or-unavailable"
        )

    output, error = run_command(
        ["sinfo", "-h", "-o", "%N|%T"]
    )

    if error:
        return result(
            "slurm", "ERROR", error,
            {"services": service_states}
        )

    nodes = []

    for line in output.splitlines():
        if "|" not in line:
            continue

        name, state = line.split("|", 1)
        nodes.append({
            "name": name.strip(),
            "state": state.strip(),
        })

    services_active = all(
        state == "active" for state in service_states.values()
    )

    unhealthy_states = {
        "down", "drain", "drained", "fail", "failed",
        "unknown", "not_responding",
    }

    nodes_healthy = bool(nodes) and all(
        not any(
            node["state"].lower().startswith(state)
            for state in unhealthy_states
        )
        for node in nodes
    )

    healthy = services_active and nodes_healthy

    return result(
        "slurm",
        "OK" if healthy else "WARNING",
        "Slurm services and nodes healthy"
        if healthy else "Slurm requires investigation",
        {"services": service_states, "nodes": nodes},
    )


def fetch_json(url):
    try:
        with urlopen(url, timeout=5) as response:
            return json.load(response), None
    except (HTTPError, URLError, TimeoutError, ValueError, OSError) as exc:
        return None, str(exc)


def check_prometheus(base_url):
    base_url = base_url.rstrip("/")

    try:
        with urlopen(base_url + "/-/ready", timeout=5) as response:
            ready = response.status == 200
    except (HTTPError, URLError, TimeoutError, OSError) as exc:
        return result(
            "prometheus", "ERROR",
            f"Readiness check failed: {exc}"
        )

    payload, error = fetch_json(base_url + "/api/v1/rules")

    if error:
        return result("prometheus", "ERROR", error)

    if payload.get("status") != "success":
        return result(
            "prometheus", "ERROR",
            "Prometheus rules API returned an unsuccessful response"
        )

    alerts = []

    for group in payload.get("data", {}).get("groups", []):
        for rule in group.get("rules", []):
            if rule.get("type") != "alerting":
                continue

            alerts.append({
                "name": rule.get("name"),
                "state": rule.get("state"),
                "health": rule.get("health"),
            })

    firing = [
        alert["name"]
        for alert in alerts
        if alert["state"] == "firing"
    ]

    unhealthy = [
        alert["name"]
        for alert in alerts
        if alert["health"] != "ok"
    ]

    healthy = ready and not firing and not unhealthy

    return result(
        "prometheus",
        "OK" if healthy else "WARNING",
        "Prometheus Ready; no firing or unhealthy alert rules"
        if healthy else "Prometheus alerting requires investigation",
        {
            "ready": ready,
            "alert_count": len(alerts),
            "firing_alerts": firing,
            "unhealthy_rules": unhealthy,
            "alerts": alerts,
        },
    )


def main():
    parser = argparse.ArgumentParser(
        description="LAB-012 infrastructure diagnostics"
    )

    parser.add_argument(
        "--prometheus-url",
        default="http://127.0.0.1:9091",
        help="Prometheus URL (default: http://127.0.0.1:9091)",
    )

    parser.add_argument(
        "--output",
        help="Optional JSON report path",
    )

    args = parser.parse_args()

    checks = [
        check_kubernetes(),
        check_slurm(),
        check_prometheus(args.prometheus_url),
    ]

    statuses = [check["status"] for check in checks]

    if "ERROR" in statuses:
        overall = "ERROR"
    elif "WARNING" in statuses:
        overall = "WARNING"
    else:
        overall = "OK"

    report = {
        "lab": "LAB-012",
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "overall_status": overall,
        "checks": checks,
    }

    output = json.dumps(report, indent=2)

    if args.output:
        destination = Path(args.output)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(output + "\n", encoding="utf-8")
        print(f"Report saved: {destination}")

    print(output)

    return 0 if overall == "OK" else 1


if __name__ == "__main__":
    sys.exit(main())
