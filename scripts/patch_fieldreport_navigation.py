#!/usr/bin/env python3
"""Patch fieldreport robot suites to use React shell + legacy iframe navigation."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1] / "FinalistenTestCases" / "fieldreport"

NAV_RESOURCE = "Resource         ../keywords/NavigationKeyword.robot\n"

NEW_NAV_KEYWORD = '''Navigate To Field Report List
    [Documentation]    Login and navigate to the Field Report list view (React shell + legacy iframe).
    Open And Login
    Navigate To Legacy Path    /fieldreport/list/
    Select Legacy Content Frame
    Wait Until Keyword Succeeds    3x    5s    Wait Until Page Contains Element    ${FILTER_SECTION_HEADER}    timeout=15s
    ${count}=    Get Element Count    ${FIELD_REPORT_ROWS}
    IF    ${count} == 0
        Log To Console    No records found with default filters. Performing initial rolling search...
        Search Until Records Are Found
    END

'''

# Files that define their own Navigate To Field Report List with old menu hover
FILES_WITH_LOCAL_NAV = [
    "search_filter_fieldreport.robot",
    "validation_required_fields_fieldreport.robot",
    "validation_datatype_fieldreport.robot",
    "delete_fieldreport.robot",
    "debug_earnings.robot",
    "date_validation_extended_fieldreport.robot",
    "copy_fieldreport.robot",
    "close_reopen_fieldreport.robot",
    "cascade_dropdown_fieldreport.robot",
    "approve_unapprove_fieldreport.robot",
]


def ensure_nav_resource(text: str) -> str:
    if "NavigationKeyword.robot" in text:
        return text
    marker = "Resource         ../keywords/LoginKeyword.robot\n"
    if marker in text:
        return text.replace(marker, marker + NAV_RESOURCE)
    marker2 = "Resource   ../keywords/LoginKeyword.robot\n"
    if marker2 in text:
        return text.replace(marker2, marker2 + "Resource   ../keywords/NavigationKeyword.robot\n")
    return text


def strip_old_menu_keywords(text: str) -> str:
    patterns = [
        r"\nNavigate Via Menu\n.*?(?=\n[A-Z][a-z].*\n    \[)",
        r"\nHover Over Production Menu\n.*?(?=\n[A-Z][a-z].*\n    \[)",
        r"\nClick On Field Report Menu\n.*?(?=\n[A-Z][a-z].*\n    \[)",
    ]
    for pat in patterns:
        text = re.sub(pat, "\n", text, flags=re.DOTALL)
    return text


def replace_nav_keyword(text: str) -> str:
    pat = re.compile(
        r"Navigate To Field Report List\n"
        r"    \[Documentation\].*?\n"
        r"(?:    .*\n)*?"
        r"(?=Navigate Via Menu|Hover Over Production Menu|Expand Filter Section|Search Until|Open Field Report|Create Field Report|Delete Field Report|Go To Field Report)",
        re.MULTILINE,
    )
    if pat.search(text):
        return pat.sub(NEW_NAV_KEYWORD, text, count=1)
    pat2 = re.compile(
        r"Navigate To Field Report List\n"
        r"    \[Documentation\].*?\n"
        r"(?:    .*\n)*?"
        r"(?=\nExpand Filter Section|\nSearch Until|\nOpen Field Report|\nCreate Field Report)",
        re.MULTILINE,
    )
    if pat2.search(text):
        return pat2.sub(NEW_NAV_KEYWORD, text, count=1)
    return text


def patch_go_to_urls(text: str) -> str:
    text = re.sub(
        r"Go To\s+\$\{FIELDREPORT_LIST_URL\}",
        "Navigate To Legacy Path    /fieldreport/list/\n    Select Legacy Content Frame",
        text,
    )
    text = re.sub(
        r"Go To\s+https://preproderp\.finalisten\.se/fieldreport/list/",
        "Navigate To Legacy Path    /fieldreport/list/\n    Select Legacy Content Frame",
        text,
    )
    return text


def main():
    for name in FILES_WITH_LOCAL_NAV:
        path = ROOT / name
        if not path.exists():
            print("skip missing", name)
            continue
        text = path.read_text(encoding="utf-8")
        text = ensure_nav_resource(text)
        text = replace_nav_keyword(text)
        text = strip_old_menu_keywords(text)
        text = patch_go_to_urls(text)
        path.write_text(text, encoding="utf-8")
        print("patched", name)

    for path in ROOT.glob("*.robot"):
        if path.name in FILES_WITH_LOCAL_NAV or path.name.startswith("open_"):
            continue
        text = path.read_text(encoding="utf-8")
        if "PRODUCTION_MENU" not in text and "FIELDREPORT_LIST_URL" not in text and "field_reports_app_menu" not in text:
            continue
        text = ensure_nav_resource(text)
        text = patch_go_to_urls(text)
        if "Navigate To Field Report List" in text and "Navigate To Legacy Path" not in text:
            text = replace_nav_keyword(text)
            text = strip_old_menu_keywords(text)
        path.write_text(text, encoding="utf-8")
        print("patched other", path.name)


if __name__ == "__main__":
    main()
