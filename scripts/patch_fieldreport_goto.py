#!/usr/bin/env python3
"""Replace legacy Go To fieldreport URLs with iframe-aware navigation keywords."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "FinalistenTestCases" / "fieldreport"

REPLACEMENTS = [
    ("Go To    https://preproderp.finalisten.se/fieldreport/create/", "Navigate To Field Report Create Page"),
    ("Go To    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/", "Open Legacy Field Report Edit By Id    ${CREATED_FIELDREPORT_ID}"),
    ("Go To    ${edit_url}", "Navigate To Legacy Full Url    ${edit_url}"),
    ("Go To    ${deleted_url}", "Navigate To Legacy Full Url    ${deleted_url}"),
    ("Go To    ${FIELDREPORT_LIST_URL}", "Navigate To Field Report List"),
    ("Navigate To Legacy Path    /fieldreport/list/\n    Select Legacy Content Frame", "Navigate To Field Report List"),
]


def main():
    for path in ROOT.glob("*.robot"):
        text = path.read_text(encoding="utf-8")
        original = text
        for old, new in REPLACEMENTS:
            text = text.replace(old, new)
        if text != original:
            path.write_text(text, encoding="utf-8")
            print("updated", path.name)


if __name__ == "__main__":
    main()
