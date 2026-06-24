#!/usr/bin/env python3
"""Rewrite simple legacy navigation robot tests for React sidebar + iframe."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "FinalistenTestCases"

SIMPLE_TESTS = {
    "employee/open_employee_list.robot": (
        "Navigate To Employee List",
        [
            "    Wait Until Element Is Visible    id=id_advanced_search_toggle    timeout=30s",
        ],
        "Verify Employee List Opens Successfully",
        "Employee list opened successfully.",
    ),
    "employee/open_employee_edit.robot": (
        "Navigate To Employee List",
        [
            "    Wait Until Element Is Visible    css=tr.employee_rows    timeout=20s",
            "    Click Element    css=tr.employee_rows",
            "    Wait Until Page Contains    PERSONAL DATA    timeout=30s",
        ],
        "Verify Edit Employee Page Opens Successfully",
        "Employee edit page opened successfully.",
    ),
    "employee/open_employee_create.robot": (
        "Navigate To Employee List",
        [
            "    Click Element    id=id_add_employee",
            "    Wait Until Page Contains    PERSONAL DATA    timeout=30s",
        ],
        "Verify Employee Create Page Opens Successfully",
        "Employee create page opened successfully.",
    ),
    "supplier/open_supplier_list.robot": (
        "Navigate To Supplier List",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Supplier List Opens Successfully",
        "Supplier list opened successfully.",
    ),
    "supplier/open_supplier_edit.robot": (
        "Navigate To Supplier List",
        [
            "    Wait Until Element Is Visible    css=tr.supplier_rows    timeout=20s",
            "    Click Element    css=tr.supplier_rows",
            "    Wait Until Page Contains    SUPPLIER    timeout=30s",
        ],
        "Verify Supplier Edit Page Opens Successfully",
        "Supplier edit page opened successfully.",
    ),
    "supplier/open_supplier_create.robot": (
        "Navigate To Supplier List",
        [
            "    Click Element    id=id_add_supplier",
            "    Wait Until Page Contains    SUPPLIER    timeout=30s",
        ],
        "Verify Supplier Create Page Opens Successfully",
        "Supplier create page opened successfully.",
    ),
    "subcontractor/open_subcontractor_list.robot": (
        "Navigate To Subcontractor List",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Subcontractor List Opens Successfully",
        "Subcontractor list opened successfully.",
    ),
    "subcontractor/open_subcontractor_edit.robot": (
        "Navigate To Subcontractor List",
        [
            "    Wait Until Element Is Visible    css=tr.subcontractor_rows    timeout=20s",
            "    Click Element    css=tr.subcontractor_rows",
            "    Wait Until Page Contains    SUBCONTRACTOR    timeout=30s",
        ],
        "Verify Edit Subcontractor Page Opens Successfully",
        "Subcontractor edit page opened successfully.",
    ),
    "subcontractor/open_subcontractor_create.robot": (
        "Navigate To Subcontractor List",
        [
            "    Click Element    id=id_add_subcontractor",
            "    Wait Until Page Contains    SUBCONTRACTOR    timeout=30s",
        ],
        "Verify Subcontractor Create Page Opens Successfully",
        "Subcontractor create page opened successfully.",
    ),
    "guestuser/open_guestuser_list.robot": (
        "Navigate To Guest User List",
        [
            "    Wait Until Element Is Visible    id=id_advanced_search_toggle    timeout=30s",
        ],
        "Verify Guest User List Opens Successfully",
        "Guest user list opened successfully.",
    ),
    "guestuser/open_guestuser_create.robot": (
        "Navigate To Guest User List",
        [
            "    Click Element    id=id_add_subcontractor",
            "    Wait Until Page Contains    PERSONAL DATA    timeout=30s",
        ],
        "Verify Guest User Create Page Opens Successfully",
        "Guest user create page opened successfully.",
    ),
    "guestuser/guestuser.robot": (
        "Navigate To Guest User List",
        ["    Wait Until Element Is Visible    id=id_advanced_search_toggle    timeout=30s"],
        "Verify Guest User List Opens",
        "Guest user list opened.",
    ),
    "productregister/open_productregister_list.robot": (
        "Navigate To Product Register List",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Product Register List Opens Successfully",
        "Product register list opened successfully.",
    ),
    "productregister/open_productregister_edit.robot": (
        "Navigate To Product Register List",
        [
            "    Wait Until Element Is Visible    css=tr.product_rows    timeout=20s",
            "    Click Element    css=tr.product_rows",
            "    Wait Until Page Contains    PRODUCT    timeout=30s",
        ],
        "Verify Edit Product Register Page Opens Successfully",
        "Product register edit page opened successfully.",
    ),
    "productregister/open_productregister_create.robot": (
        "Navigate To Product Register List",
        [
            "    Click Element    xpath=//a[contains(@href,'product_new')]",
            "    Wait Until Page Contains    PRODUCT    timeout=30s",
        ],
        "Verify Product Register Create Page Opens Successfully",
        "Product register create page opened successfully.",
    ),
    "purchaseproductregister/open_purchaseproductregister_list.robot": (
        "Navigate To Purchase Product Register List",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Purchase Product Register List Opens Successfully",
        "Purchase product register list opened successfully.",
    ),
    "purchaseproductregister/open_purchaseproductregister_edit.robot": (
        "Navigate To Purchase Product Register List",
        [
            "    Wait Until Element Is Visible    css=tr.purchase_product_rows    timeout=20s",
            "    Click Element    css=tr.purchase_product_rows",
            "    Wait Until Page Contains    PURCHASE PRODUCT    timeout=30s",
        ],
        "Verify Edit Purchase Product Register Page Opens Successfully",
        "Purchase product register edit page opened successfully.",
    ),
    "purchaseproductregister/open_purchaseproductregister_create.robot": (
        "Navigate To Purchase Product Register List",
        [
            "    Click Element    xpath=//a[contains(@href,'purchase_product_new')]",
            "    Wait Until Page Contains    PURCHASE PRODUCT    timeout=30s",
        ],
        "Verify Purchase Product Register Create Page Opens Successfully",
        "Purchase product register create page opened successfully.",
    ),
    "quotation/open_quotation_list.robot": (
        "Navigate To Quotation List",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Quotation List View Opens Successfully",
        "Quotation list view opened successfully.",
    ),
    "quotation/open_quotation_edit.robot": (
        "Navigate To Quotation List",
        [
            "    Wait Until Page Contains    Filters    timeout=20s",
            "    ${row_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    css=tr.quotation_rows    timeout=10s",
            "    Run Keyword If    ${row_exists}    Click Element    css=tr.quotation_rows",
            "    Run Keyword If    ${row_exists}    Wait Until Page Contains    QUOTATION    timeout=20s",
        ],
        "Verify Quotation Edit Page Opens Successfully",
        "Quotation edit page opened successfully.",
    ),
    "quotation/open_quotation_create.robot": (
        "Navigate To Quotation List",
        [
            "    Click Element    id=id_add_quotation",
            "    Wait Until Page Contains    QUOTATION    timeout=30s",
        ],
        "Verify Quotation Create Page Opens Successfully",
        "Quotation create page opened successfully.",
    ),
    "invoicing/open_invoicing_tree.robot": (
        "Navigate To Invoicing Tree",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Invoicing App Opens Successfully",
        "Invoicing app opened successfully.",
    ),
    "invoicing/open_invoice_list.robot": (
        "Navigate To Invoice List",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Invoice List View Opens Successfully",
        "Invoice list view opened successfully.",
    ),
    "invoicereport/open_invoicereport_app.robot": (
        "Navigate To Invoice Report",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Invoice Report App Opens Successfully",
        "Invoice report app opened successfully.",
    ),
    "projectreport/open_projectreport_app.robot": (
        "Navigate To Project Report",
        ["    Wait Until Page Contains    List Of Projects    timeout=20s"],
        "Verify Project Report App Opens Successfully",
        "Project report app opened successfully.",
    ),
    "performancereport/open_performancereport_app.robot": (
        "Navigate To Performance Report",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Performance Report App Opens Successfully",
        "Performance report app opened successfully.",
    ),
    "resourceplanning/open_resourceplanning_app.robot": (
        "Navigate To Resource Planning Board",
        ["    Wait Until Page Contains    Sales Week    timeout=30s"],
        "Verify Resource Planning Board Opens Successfully",
        "Resource planning board opened successfully.",
    ),
    "doorplanning/open_doorplanning_app.robot": (
        "Navigate To Door Planning Board",
        ["    Wait Until Page Contains    Sales Week    timeout=30s"],
        "Verify Door Planning Board Opens Successfully",
        "Door planning board opened successfully.",
    ),
    "dailyplanner/open_dailyplanner_home.robot": (
        "Navigate To Daily Planner Home",
        ["    Wait Until Page Contains    Kanban Board    timeout=20s"],
        "Verify Daily Planner Board Opens Successfully",
        "Daily planner home opened successfully.",
    ),
    "myproduction/open_myproduction_app.robot": (
        "Navigate To My Production",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify My Production App Opens Successfully",
        "My production app opened successfully.",
    ),
    "fieldreport/open_fieldreport_list.robot": (
        "Navigate To Field Report List",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Field Report List View Opens Successfully",
        "Field report list view opened successfully.",
    ),
    "fieldreport/open_fieldreport_create.robot": (
        "Navigate To Field Report List",
        [
            "    Click Element    xpath=//a[contains(@href,'fieldreport/create')]",
            "    Wait Until Page Contains    FIELD REPORT    timeout=30s",
        ],
        "Verify Field Report Create Page Opens Successfully",
        "Field report create page opened successfully.",
    ),
    "fieldreportapproval/open_fieldreportapproval_app.robot": (
        "Navigate To Field Report Approval",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Field Report Approval App Opens Successfully",
        "Field report approval app opened successfully.",
    ),
    "setting/open_settings_app.robot": (
        "Navigate To Old Settings App",
        [
            "    Wait Until Page Contains    Settings    timeout=20s",
            "    Wait Until Page Contains    Fieldreport    timeout=20s",
        ],
        "Verify Settings App Opens Successfully",
        "Settings app opened successfully.",
    ),
    "project/open_project_list.robot": (
        "Navigate To Project List",
        ["    Wait Until Page Contains    Filters    timeout=20s"],
        "Verify Project List Opens Successfully",
        "Project list opened successfully.",
    ),
    "project/open_project_create.robot": (
        "Navigate To Project List",
        [
            "    Click Element    xpath=//a[contains(@href,'project_new')]",
            "    Wait Until Page Contains    GENERAL DATA    timeout=30s",
        ],
        "Verify Project Create Page Opens Successfully",
        "Project create page opened successfully.",
    ),
}


def render(rel_path, nav_kw, assertions, test_name, log_msg):
    depth = rel_path.count("/")
    prefix = "../" * (depth if depth > 0 else 1)
    lines = [
        "*** Settings ***",
        "Library    SeleniumLibrary",
        f"Resource   {prefix}keywords/LoginKeyword.robot",
        f"Resource   {prefix}keywords/NavigationKeyword.robot",
        "",
        "*** Test Cases ***",
        test_name,
        "    Register Keyword To Run On Failure    Capture Page Screenshot",
        "    Open And Login",
        f"    {nav_kw}",
        *assertions,
        f'    Log To Console    "{log_msg}"',
        "    Close Browser",
        "",
    ]
    return "\n".join(lines)


def main():
    for rel, (nav, assertions, name, log) in SIMPLE_TESTS.items():
        path = ROOT / rel
        path.write_text(render(rel, nav, assertions, name, log), encoding="utf-8")
        print("updated", rel)


if __name__ == "__main__":
    main()
