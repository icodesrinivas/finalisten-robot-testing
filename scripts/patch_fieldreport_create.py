#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "FinalistenTestCases" / "fieldreport"

for path in ROOT.glob("*.robot"):
    text = path.read_text(encoding="utf-8")
    original = text
    text = text.replace("Go To    ${FIELDREPORT_CREATE_URL}", "Navigate To Field Report Create Page")
    text = text.replace("Go To    ${PREPROD_FIELDREPORT_CREATE_URL}", "Navigate To Field Report Create Page")
    text = text.replace(
        "Wait Until Keyword Succeeds    5x    5s    Location Should Contain    /edit/",
        "Wait Until Field Report Saved To Edit Page",
    )
    text = text.replace(
        "Wait Until Keyword Succeeds    10x    3s    Location Should Contain    /edit/",
        "Wait Until Field Report Saved To Edit Page",
    )
    if text != original:
        path.write_text(text, encoding="utf-8")
        print("updated", path.name)
