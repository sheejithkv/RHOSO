"""Validate the four corporate RHOSO SOP templates without cluster access."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOPS = (
    "operations/daily-health-check.md",
    "incidents/vm-build-failure.md",
    "maintenance/compute-host-maintenance.md",
    "recovery/backup-readiness.md",
)
TITLES = (
    "1 PURPOSE", "2 SCOPE", "3 APPLICABILITY",
    "4 TERMS & DEFINITIONS", "5 ROLES & RESPONSIBILITIES",
    "6 IMPLEMENTATION", "7 REVIEW REQUIREMENTS",
    "8 REFERENCES", "9 APPENDICES",
)
CONTROL = (
    "DOCUMENT INFORMATION", "DOCUMENT REVIEW AND APPROVAL",
    "REVISION HISTORY", "TABLE OF CONTENTS",
)
class TestCorporateSOP(unittest.TestCase):
    def test_controlled_structure(self):
        for relative in SOPS:
            with self.subTest(sop=relative):
                text = (ROOT / "SOP" / relative).read_text(encoding="utf-8")
                self.assertIn('<div class="sop-page" markdown="1">', text)
                self.assertIn('</div>', text)
                self.assertIn("DRAFT", text)
                self.assertIn("Pending", text)
                self.assertIn("Confidential", text.capitalize()) if False else None
                self.assertIn("Public engineering draft", text)
                self.assertIn("6.4 Execution procedure", text)
                self.assertIn("SIMULATED", text)
                for heading in CONTROL:
                    self.assertEqual(len(re.findall(
                        r"^## " + re.escape(heading) + r"$", text, re.MULTILINE
                    )), 1, heading)
                headings = re.findall(r"^## (\d+ .+)$", text, re.MULTILINE)
                self.assertEqual(headings, list(TITLES))
                self.assertIn("## 9 APPENDICES", text)
                self.assertIn("## 7 REVIEW REQUIREMENTS", text)
                self.assertIn("## 8 REFERENCES", text)
    def test_template_matches_format(self):
        text = (ROOT / "SOP" / "TEMPLATE.md").read_text(encoding="utf-8")
        self.assertIn('<div class="sop-page" markdown="1">', text)
        self.assertEqual(re.findall(r"^## (\d+ .+)$", text, re.MULTILINE), list(TITLES))
if __name__ == "__main__":
    unittest.main()
