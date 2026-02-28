#!/bin/bash
# Quick test script to verify AppScan authentication

set -e

APPSCAN_KEY_ID="5079dd89-2c68-4f4a-4052-25094a7a7798"
APPSCAN_KEY_SECRET="6jcVh9ztN1uxo2hlFg4AQ6lMV9b3IDYTghzAY8xps7PF"
APPSCAN="appscan.sh"

echo "=========================================="
echo "Testing AppScan Authentication"
echo "=========================================="
echo ""

# Check if appscan.sh is available
if ! command -v appscan.sh &> /dev/null; then
    echo "Error: appscan.sh not found in PATH"
    exit 1
fi

echo "AppScan CLI found: $(which appscan.sh)"
echo ""

# Test login
echo "Testing authentication..."
echo "Key ID: $APPSCAN_KEY_ID"
echo ""

LOGIN_OUTPUT=$(appscan.sh api_login -u "$APPSCAN_KEY_ID" -P "$APPSCAN_KEY_SECRET" 2>&1)
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
