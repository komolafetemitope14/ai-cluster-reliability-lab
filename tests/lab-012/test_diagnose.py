
#!/usr/bin/env python3
"""Automated tests for LAB-012 infrastructure diagnostics."""

import importlib.util
import json
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/python/lab-012/diagnose.py"

spec = importlib.util.spec_from_file_location("lab012_diagnose", SCRIPT)
diagnose = importlib.util.module_from_spec(spec)
spec.loader.exec_module(diagnose)


class KubernetesTests(unittest.TestCase):

    @patch.object(diagnose, "run_command")
    def test_healthy_node(self, mock_run):
        nodes = {
            "items": [
                {
                    "metadata": {"name": "test-node"},
                    "status": {
                        "conditions": [
                            {"type": "Ready", "status": "True"}
                        ]
                    },
                }
            ]
        }

        mock_run.side_effect = [
            ("kind-test", None),
            (json.dumps(nodes), None),
        ]

        check = diagnose.check_kubernetes()

        self.assertEqual(check["status"], "OK")
        self.assertTrue(check["details"]["nodes"][0]["ready"])

    @patch.object(diagnose, "run_command")
    def test_not_ready_node(self, mock_run):
        nodes = {
            "items": [
                {
                    "metadata": {"name": "test-node"},
                    "status": {
                        "conditions": [
                            {"type": "Ready", "status": "False"}
                        ]
                    },
                }
            ]
        }

        mock_run.side_effect = [
            ("kind-test", None),
            (json.dumps(nodes), None),
        ]

        check = diagnose.check_kubernetes()

        self.assertEqual(check["status"], "WARNING")

    @patch.object(diagnose, "run_command")
    def test_kubectl_failure(self, mock_run):
        mock_run.return_value = (
            None,
            "Unable to connect to Kubernetes API",
        )

        check = diagnose.check_kubernetes()

        self.assertEqual(check["status"], "ERROR")


class SlurmTests(unittest.TestCase):

    @patch.object(diagnose, "run_command")
    def test_healthy_slurm(self, mock_run):
        mock_run.side_effect = [
            ("active", None),
            ("active", None),
            ("active", None),
            ("test-node|idle", None),
        ]

        check = diagnose.check_slurm()

        self.assertEqual(check["status"], "OK")

    @patch.object(diagnose, "run_command")
    def test_inactive_service(self, mock_run):
        mock_run.side_effect = [
            ("active", None),
            (None, "inactive"),
            ("active", None),
            ("test-node|idle", None),
        ]

        check = diagnose.check_slurm()

        self.assertEqual(check["status"], "WARNING")

    @patch.object(diagnose, "run_command")
    def test_down_node(self, mock_run):
        mock_run.side_effect = [
            ("active", None),
            ("active", None),
            ("active", None),
            ("test-node|down", None),
        ]

        check = diagnose.check_slurm()

        self.assertEqual(check["status"], "WARNING")


class PrometheusTests(unittest.TestCase):

    @patch.object(diagnose, "fetch_json")
    @patch.object(diagnose, "urlopen")
    def test_healthy_alerts(self, mock_urlopen, mock_fetch):
        mock_urlopen.return_value.__enter__.return_value.status = 200

        mock_fetch.return_value = (
            {
                "status": "success",
                "data": {
                    "groups": [
                        {
                            "rules": [
                                {
                                    "type": "alerting",
                                    "name": "TestAlert",
                                    "state": "inactive",
                                    "health": "ok",
                                }
                            ]
                        }
                    ]
                },
            },
            None,
        )

        check = diagnose.check_prometheus(
            "http://127.0.0.1:9091"
        )

        self.assertEqual(check["status"], "OK")

    @patch.object(diagnose, "fetch_json")
    @patch.object(diagnose, "urlopen")
    def test_firing_alert(self, mock_urlopen, mock_fetch):
        mock_urlopen.return_value.__enter__.return_value.status = 200

        mock_fetch.return_value = (
            {
                "status": "success",
                "data": {
                    "groups": [
                        {
                            "rules": [
                                {
                                    "type": "alerting",
                                    "name": "SyntheticFailure",
                                    "state": "firing",
                                    "health": "ok",
                                }
                            ]
                        }
                    ]
                },
            },
            None,
        )

        check = diagnose.check_prometheus(
            "http://127.0.0.1:9091"
        )

        self.assertEqual(check["status"], "WARNING")
        self.assertIn(
            "SyntheticFailure",
            check["details"]["firing_alerts"],
        )

    @patch.object(diagnose, "urlopen")
    def test_prometheus_unreachable(self, mock_urlopen):
        mock_urlopen.side_effect = OSError(
            "Connection refused"
        )

        check = diagnose.check_prometheus(
            "http://127.0.0.1:9091"
        )

        self.assertEqual(check["status"], "ERROR")


if __name__ == "__main__":
    unittest.main()
