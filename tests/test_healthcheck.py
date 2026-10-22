"""Read-only simulated health-check contract tests; no cluster access."""
import json
import os
import pathlib
import subprocess
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "rhoso-healthcheck.sh"

FAKE_OC = r'''#!/usr/bin/env python3
import json, os, sys
args=sys.argv[1:]
if args==["whoami"]:
    print("mock-admin")
    sys.exit(0)
if args[:2]==["get","clusterversion"]:
    print(json.dumps({"status":{"conditions":[{"type":"Available","status":"True"}]}}))
    sys.exit(0)
if args[:2]==["get","clusteroperators"]:
    print(os.environ["MOCK_OPERATORS"])
    sys.exit(0)
if args[:2]==["get","nodes"]:
    print(json.dumps({"items":[{"status":{"conditions":[{"type":"Ready","status":"True"}]}}]}))
    sys.exit(0)
if args[:2]==["get","openstackcontrolplane"]:
    print(json.dumps({"items":[]}))
    sys.exit(0)
if args[:2]==["get","events"]:
    print(json.dumps({"items":[]}))
    sys.exit(0)
print("UNEXPECTED MOCK OC READ:",args,file=sys.stderr)
sys.exit(4)
'''

def operators(*conditions):
    return {"items":[{"metadata":{"name":"mock-operator"},
        "status":{"conditions":[{"type":key,"status":value} for key,value in conditions]}}]}

class TestHealthCheckClassification(unittest.TestCase):
    def check_operators(self, conditions, expected):
        with tempfile.TemporaryDirectory() as temp:
            folder = pathlib.Path(temp)
            exe = folder / "oc"
            exe.write_text(FAKE_OC, encoding="utf-8")
            exe.chmod(0o755)
            env = os.environ.copy()
            env["PATH"] = str(folder) + os.pathsep + env["PATH"]
            env["MOCK_OPERATORS"] = json.dumps(operators(*conditions))
            env["RHOSO_REPORT_DIR"] = str(folder / "health-output")
            result = subprocess.run(["bash", str(SCRIPT)], env=env,
                                    capture_output=True, text=True, timeout=20)
            self.assertIn(result.returncode, (1,2), result.stderr)
            summary = (folder / "health-output" / "summary.tsv").read_text()
            operator_lines = [line for line in summary.splitlines()
                              if "\tclusteroperators\t" in line]
            self.assertEqual(len(operator_lines), 1, summary)
            self.assertEqual(operator_lines[0].split("\t")[0], expected)
            # No writes or unauthorized calls have occurred; mock rejects unexpected oc.
            self.assertNotIn("secret=", result.stdout.lower())
    def test_all_conditions_healthy(self):
        self.check_operators([("Available","True"),("Degraded","False"),
                              ("Progressing","False")], "PASS")
    def test_available_missing_is_not_pass(self):
        self.check_operators([("Degraded","False"),("Progressing","False")], "WARN")
    def test_progressing_is_not_pass(self):
        self.check_operators([("Available","True"),("Degraded","False"),
                              ("Progressing","True")], "WARN")
    def test_available_false_is_fail(self):
        self.check_operators([("Available","False"),("Degraded","False"),
                              ("Progressing","False")], "FAIL")
    def test_degraded_true_is_fail(self):
        self.check_operators([("Available","True"),("Degraded","True"),
                              ("Progressing","False")], "FAIL")

if __name__=="__main__":
    unittest.main()
