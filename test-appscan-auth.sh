#!/bin/bash
# Quick test script to verify AppScan authentication

set -e

APPSCAN_KEY_ID="5079dd89-2c68-4f4a-4052-25094a7a7798"
APPSCAN_KEY_SECRET="6jcVh9ztN1uxo2hlFg4AQ6lMV9b3IDYTghzAY8xps7PF"
APPSCAN_DIR="/home/control5/Tools/AppScan/SAClientUtil_8.0.1685_Linux/SAClientUtil.8.0.1685/bin"

echo "=========================================="
echo "Testing AppScan Authentication"
echo "=========================================="
echo ""

# List AppScan executables
echo "Looking for AppScan executables in: $APPSCAN_DIR"
if [ -d "$APPSCAN_DIR" ]; then
    echo "Files in AppScan bin directory:"
    ls -la "$APPSCAN_DIR" | grep -E "(appscan|appscancmd)" || echo "No appscan* files found"
    echo ""
fi

# Try to find the correct AppScan command
if [ -f "$APPSCAN_DIR/appscan.sh" ]; then
    APPSCAN="$APPSCAN_DIR/appscan.sh"
elif [ -f "$APPSCAN_DIR/appscan" ]; then
    APPSCAN="$APPSCAN_DIR/appscan"
elif [ -f "$APPSCAN_DIR/appscancmd.sh" ]; then
    APPSCAN="$APPSCAN_DIR/appscancmd.sh"
elif [ -f "$APPSCAN_DIR/appscancmd" ]; then
    APPSCAN="$APPSCAN_DIR/appscancmd"
else
    echo "Error: Could not find AppScan executable"
    echo "Please check the installation directory"
    exit 1
fi

echo "AppScan CLI found: $APPSCAN"
echo ""

# Test login
echo "Testing authentication..."
echo "Key ID: $APPSCAN_KEY_ID"
echo ""

LOGIN_OUTPUT=$("$APPSCAN" api_login -u "$APPSCAN_KEY_ID" -P "$APPSCAN_KEY_SECRET" 2>&1)
LOGIN_EXIT_CODE=$?

echo "$LOGIN_OUTPUT"
echo ""

if [ $LOGIN_EXIT_CODE -eq 0 ]; then
    if echo "$LOGIN_OUTPUT" | grep -q "Authenticated successfully"; then
        echo "=========================================="
        echo "✓ Authentication successful!"
        echo "=========================================="
        exit 0
    else
        echo "=========================================="
        echo "⚠ Login command succeeded but no confirmation message"
        echo "=========================================="
        exit 1
    fi
else
    echo "=========================================="
    echo "✗ Authentication failed (exit code: $LOGIN_EXIT_CODE)"
    echo "=========================================="
    exit 1
fi
