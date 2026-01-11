# Jenkins Job Manual Fix Required

## Issue:
The Jenkins job is failing because it's configured to use a local Git path instead of the GitHub repository URL.

## Quick Fix (1 minute):

1. Open: http://localhost:8080/job/Robot-Framework-Tests/configure
2. Login: admin / admin123
3. Scroll to the **"Pipeline"** section
4. Under **"SCM"**, the Repository URL currently shows a local path
5. Change **"Repository URL"** to: `https://github.com/icodesrinivas/finalisten-robot-testing.git`
6. Change **"Branch Specifier"** to: `*/main`
7. Click **"Save"** at bottom
8. Click **"Build Now"**

The tests will then run successfully and send emails to both recipients!

**Alternative - Use Local Repository Without Git:**
If you prefer to run tests from the local directory without GitHub:
1. Change Pipeline → Definition to: **"Pipeline script"**
2. Copy the entire Jenkinsfile content into the script box
3. Click "Save" and "Build Now"
