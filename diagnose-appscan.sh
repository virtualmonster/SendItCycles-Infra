#!/bin/bash
# Diagnostic script to debug AppScan authentication

echo "=========================================="
echo "AppScan Diagnostic Script"
echo "=========================================="
echo ""

# Show environment
echo "=== Environment ==="
echo "PATH: $PATH"
echo "HOME: $HOME"
echo "USER: $USER"
echo ""

# Check where appscan is
echo "=== Looking for AppScan ==="
if command -v appscan &> /dev/null; then
    APPSCAN=$(command -v appscan)
    echo "Found: $APPSCAN"
    echo ""
    echo "=== AppScan Version ==="
    appscan version || echo "Version command failed"
else
    echo "appscan not in PATH"
fi
echo ""

# Try direct paths
echo "=== Checking known AppScan paths ==="
PATHS=(
    "/home/control5/Tools/AppScan/SAClientUtil_8.0.1685_Linux/SAClientUtil.8.0.1685/bin/appscan"
    "/opt/AppScan/bin/appscan"
    "/usr/local/bin/appscan"
)

for path in "${PATHS[@]}"; do
    if [ -f "$path" ]; then
        echo "✓ Found: $path"
    else
        echo "✗ Not found: $path"
    fi
done
echo ""

# Test authentication with verbose output
echo "=== Testing Authentication ==="
APPSCAN_KEY_ID="5079dd89-2c68-4f4a-4052-25094a7a7798"
APPSCAN_KEY_SECRET="6jcVh9ztN1uxo2hlFg4AQ6lMV9b3IDYTghzAY8xps7PF"

if command -v appscan &> /dev/null; then
    echo "Running: appscan api_login"
    echo "Command: appscan api_login -u $APPSCAN_KEY_ID -P [SECRET]"
    echo ""
    appscan api_login -u "$APPSCAN_KEY_ID" -P "$APPSCAN_KEY_SECRET"
    LOGIN_EXIT=$?
    echo ""
    echo "Exit code: $LOGIN_EXIT"
else
    echo "Error: appscan command not found"
    exit 1
fi
