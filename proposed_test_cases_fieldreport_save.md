# Proposed Test Cases: Fieldreport Edit Page Save Validation

**Created:** 2026-01-21  
**Status:** Pending Client Approval  
**Related Bug Fix:** Fieldreport Edit Page 400 Bad Request Error  

---

## Background

On 2026-01-21, a bug was fixed in the Finalisten ERP system where saving a field report edit page resulted in a `400 Bad Request` error. The root causes were:

1. **`installer_name` validation error** - "Select a valid choice. That choice is not one of the available choices." The form's queryset didn't include inactive installers who were previously assigned to existing field reports.
2. **`related_subproject` field validation** - The cascade dropdown validation wasn't properly handling subproject selections.

The following test cases are proposed to ensure this bug is caught in the daily automated tests if it ever regresses.

---

## Proposed Test Cases

### Test Case 1: Save Field Report with Inactive Installer (HIGH PRIORITY)

| Attribute | Value |
|-----------|-------|
| **File Name** | `save_inactive_installer_fieldreport.robot` |
| **Tags** | `fieldreport`, `save`, `installer`, `regression`, `preprod` |
| **Priority** | HIGH |
| **Environment** | Pre-Production |

**Purpose:**  
Ensure that saving a field report edit page works correctly when the originally assigned installer has since become **inactive**.

**Test Steps:**
1. Login to pre-production
2. Find/use an existing field report that has an **inactive installer** already assigned
3. Open the edit page
4. Click the Edit button to enable form fields
5. Make a minor edit (e.g., change the "Message to Approver" text)
6. Click Save
7. Verify save succeeds (no error messages, still on edit page)
8. Refresh the page
9. Verify the inactive installer is still selected in the dropdown

**Expected Result:**  
- Save should succeed (HTTP 200)
- No "Select a valid choice" error should appear
- The inactive installer should remain selected after save and page refresh

**Bug It Prevents:**  
`installer_name` validation error when queryset doesn't include inactive but previously-assigned installers.

---

### Test Case 2: Save with Subproject Change - Cascade Validation (HIGH PRIORITY)

| Attribute | Value |
|-----------|-------|
| **File Name** | `save_cascade_dropdown_fieldreport.robot` |
| **Tags** | `fieldreport`, `save`, `cascade`, `dropdown`, `regression`, `preprod` |
| **Priority** | HIGH |
| **Environment** | Pre-Production |

**Purpose:**  
Ensure that when `related_customer` → `related_project` → `related_subproject` cascade changes occur, the save operation validates correctly.

**Test Steps:**
1. Login to pre-production
2. Create a new field report OR open an existing field report edit page
3. Click the Edit button to enable form fields
4. Change the Customer (this triggers AJAX to reload Projects)
5. Wait 2 seconds for Projects dropdown to load
6. Select a new Project (this triggers AJAX to reload Subprojects)
7. Wait 2 seconds for Subprojects dropdown to load
8. Select a new Subproject
9. Click Save
10. Verify save succeeds
11. Refresh the page
12. Verify Customer, Project, AND Subproject are all correctly persisted

**Expected Result:**  
- Save should succeed without validation errors
- All three cascade fields (Customer/Project/Subproject) should be correctly persisted

**Bug It Prevents:**  
`related_subproject` validation error when cascade dropdowns are changed before save.

---

### Test Case 3: Change Installer to Different Active Installer and Save (MEDIUM PRIORITY)

| Attribute | Value |
|-----------|-------|
| **File Name** | `change_installer_save_fieldreport.robot` |
| **Tags** | `fieldreport`, `save`, `installer`, `preprod` |
| **Priority** | MEDIUM |
| **Environment** | Pre-Production |

**Purpose:**  
Verify that changing the installer dropdown selection and saving works correctly.

**Test Steps:**
1. Login to pre-production
2. Open any existing field report edit page
3. Record the currently selected installer
4. Click the Edit button
5. Select a DIFFERENT active installer from the dropdown
6. Click Save
7. Verify save succeeds
8. Refresh the page
9. Verify the new installer is selected (not the original one)

**Expected Result:**  
- Save should succeed
- New installer should be persisted after page refresh

**Bug It Prevents:**  
General installer field save bugs and dropdown form binding issues.

---

### Test Case 4: Verify HTTP 400 Error Detection on Save (MEDIUM PRIORITY)

| Attribute | Value |
|-----------|-------|
| **File Name** | `detect_400_error_fieldreport.robot` |
| **Tags** | `fieldreport`, `save`, `error`, `validation`, `preprod` |
| **Priority** | MEDIUM |
| **Environment** | Pre-Production |

**Purpose:**  
Explicitly verify that the daily test catches any `400 Bad Request` errors during save operations by checking for error indicators.

**Test Steps:**
1. Login to pre-production
2. Open any field report edit page
3. Click Edit button
4. Make modifications to multiple fields (Work Date, Total Hours, Message, Installer)
5. Click Save
6. Check for absence of:
   - Error toast/alert messages
   - "Bad Request" text on page
   - Form validation error highlights (red borders, error text)
7. Verify URL still contains `/edit/` (confirming we stayed on edit page)
8. Verify success indicator (if any exists in the UI)

**Expected Result:**  
- No HTTP 400 errors
- No error messages displayed
- Save should succeed cleanly

**Bug It Prevents:**  
Any 400 Bad Request errors that may not be obvious from field-level validation.

---

### Test Case 5: Save Without Making Changes - Idempotent Save (LOW PRIORITY)

| Attribute | Value |
|-----------|-------|
| **File Name** | `idempotent_save_fieldreport.robot` |
| **Tags** | `fieldreport`, `save`, `edge-case`, `preprod` |
| **Priority** | LOW |
| **Environment** | Pre-Production |

**Purpose:**  
Verify that clicking save without making any changes doesn't cause validation errors.

**Test Steps:**
1. Login to pre-production
2. Open an existing field report edit page
3. Record all current field values
4. Click the Edit button
5. Immediately click Save WITHOUT changing anything
6. Verify save succeeds
7. Refresh the page
8. Verify all field values remain unchanged

**Expected Result:**  
- Save should succeed without errors
- Page should remain on edit page
- No data should be altered

**Bug It Prevents:**  
Edge case validation bugs when form is submitted with no modifications.

---

## Summary

| Priority | Test Case Name | Focus Area |
|----------|----------------|------------|
| **HIGH** | Save with Inactive Installer | `installer_name` queryset fix |
| **HIGH** | Save with Subproject Change | Cascade dropdown validation fix |
| **MEDIUM** | Change Installer and Save | Installer field persistence |
| **MEDIUM** | HTTP 400 Error Detection | Error response monitoring |
| **LOW** | Idempotent Save | Edge case coverage |

---

## Estimated Effort

| Test Case | Development Time | Notes |
|-----------|------------------|-------|
| Test Case 1 | 2-3 hours | May need test data setup for inactive installer |
| Test Case 2 | 1-2 hours | Similar to existing `edit_fieldreport_preprod.robot` |
| Test Case 3 | 1 hour | Simple modification of existing test |
| Test Case 4 | 1-2 hours | Requires error detection logic |
| Test Case 5 | 30 mins | Simple test case |

**Total Estimated Effort:** 6-9 hours

---

## Approval

- [ ] Client Approved
- [ ] Development Scheduled
- [ ] Implemented
- [ ] Added to Daily Test Run

**Client Approval Date:** _________________  
**Approved By:** _________________
