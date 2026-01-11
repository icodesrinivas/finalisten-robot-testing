# Quick Jenkins SMTP Configuration Guide

## Step 1: Open Jenkins
1. Go to: **http://localhost:8080**
2. Login with: **admin / admin123**

## Step 2: Configure SMTP
1. Click **Manage Jenkins** (left sidebar)
2. Click **System** 
3. Scroll down to **"Extended E-mail Notification"** section
4. Click **"Advanced..."** button
5. Fill in:
   - **User Name**: `srinivas8862@gmail.com`
   - **Password**: `phsnzvtatgjuwkut`
6. Scroll to **"E-mail Notification"** section  
7. Click **"Advanced..."** button
8. Fill in:
   - **User Name**: `srinivas8862@gmail.com`
   - **Password**: `phsnzvtatgjuwkut`
9. Check "Test configuration by sending test e-mail"
10. Enter: `srinivas8862@gmail.com`
11. Click **"Test configuration"**
12. Should see: "Email was successfully sent"
13. Click **"Save"** at bottom

## Step 3: Create Jenkins Job
1. Click **"New Item"** (left sidebar)
2. Enter name: `Robot-Framework-Tests`
3. Select **"Pipeline"**
4. Click **OK**
5. Scroll to **"Pipeline"** section
6. Select **"Pipeline script from SCM"**
7. SCM: **Git**
8. Repository URL: `/Users/sreesrini/Desktop/Python_Work/FinalistenTesting/finalisten-robot-testing`
9. Branch: `*/master` (or `*/main`)
10. Script Path: `Jenkinsfile`
11. Click **Save**

## Step 4: Run the Job
1. Click **"Build Now"**
2. Wait for completion
3. Check your email: `srinivas8862@gmail.com`

---

**I can help you complete Steps 2-4 if you open Jenkins in your browser and let me know when you're ready!**
