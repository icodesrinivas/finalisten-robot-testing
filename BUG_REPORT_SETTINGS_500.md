# Bug Report: 500 Internal Server Error in Settings Edit View

**Module:** Settings -> Fieldreport -> Reporting Date Range
**Environment:** Pre-Production (https://preproderp.finalisten.se/)
**Date:** 04-03-2026

## Issue Description
When navigating to the Global Settings page and attempting to edit the "Reporting Date Range" under the Fieldreport section, the application throws a 500 Internal Server Error. This prevents the edit form form loading, rendering the user unable to update the date range.

## Steps to Reproduce
1. Login to pre-production (https://preproderp.finalisten.se/login/).
2. Hover over the "Register" menu and click "Settings".
3. Inside the Settings tree, expand the "Fieldreport" node.
4. Locate the "Reporting Date Range" setting and click its pencil icon to edit.
5. Observe that the form fields do not load.

## Root Cause Analysis
An inspection of the browser's Network tab reveals that clicking the edit (pencil) icon triggers an AJAX `GET` request to the following endpoint:
`/global_setting/global_setting_edit_view/`

The server responds with a `500 Internal Server Error` instead of returning the expected HTML form content. Because the server crashes and returns an error page/response, the fields (`id_work_date_start` and `id_work_date_end`) are never rendered in the DOM.

## Impact
*   Users currently cannot modify the start and end boundaries for valid Fieldreport dates in Pre-Production.
*   The automated Robot test case `Update Field Report Date Range` correctly fails as it waits for the `id_work_date_start` field which never appears.
