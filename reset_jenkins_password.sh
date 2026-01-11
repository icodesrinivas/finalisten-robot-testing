#!/bin/bash
# Jenkins Password Reset Script

echo "=== Jenkins Password Reset ==="
echo ""
echo "Found Jenkins users:"
ls -1 ~/.jenkins/users/ | grep -v "users.xml"
echo ""
echo "Stopping Jenkins..."
brew services stop jenkins-lts

echo ""
echo "Disabling security temporarily..."
# Backup config
cp ~/.jenkins/config.xml ~/.jenkins/config.xml.backup

# Disable security
sed -i.bak 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/' ~/.jenkins/config.xml

echo ""
echo "Starting Jenkins..."
brew services start jenkins-lts

echo ""
echo "============================================"
echo "Jenkins is starting without authentication!"
echo "Wait 30 seconds, then:"
echo "1. Open: http://localhost:8080"
echo "2. Go to: Manage Jenkins → Security"
echo "3. Create new admin user or reset password"
echo "4. Save and enable security again"
echo "============================================"
echo ""
echo "After you've reset the password, run:"
echo "  brew services restart jenkins-lts"
echo ""
