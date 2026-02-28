#!/bin/bash
# AppScan SCA Scan Script for CycleShop Frontend
# This script runs an AppScan source code analysis on the frontend repository

set -e

# Configuration
APPSCAN_KEY_ID="d538e9fa-dab5-6b1b-677d-da66e25e4ec3"
APPSCAN_KEY_SECRET="qw+ENCWyAVY7kORuIcfn3yJxZ2t9aNP66xyMjIW4omgd"
APPSCAN_APP_ID="${1:-}"  # Application ID passed as first argument
SCAN_TIMEOUT="${2:-3600}"  # Optional timeout in seconds (default: 3600)
FRONTEND_REPO_URL="https://f2264bd0d8e568db3c55f4cf2f41ab041707395c@10.134.60.169.nip.io/control/Team1/CycleShop-FrontEnd.git"
WORK_DIR=~/appscan-scans
REPO_DIR="$WORK_DIR/CycleShop-FrontEnd"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "AppScan SCA - CycleShop Frontend"
echo "=========================================="

# Validate required parameters
if [ -z "$APPSCAN_APP_ID" ]; then
    echo "Error: Application ID required"
    echo "Usage: $0 <application_id> [timeout_seconds]"
    echo "Example: $0 abc123-def456-ghi789 3600"
    exit 1
fi

# Check if appscan.sh is available
if ! command -v appscan.sh &> /dev/null; then
    echo "Error: appscan.sh not found in PATH"
    echo "Please install AppScan CLI tools first"
    exit 1
fi

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 not found"
    echo "Please install Python 3 first"
    exit 1
fi

# Create working directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Clone or update frontend repository
echo "Fetching frontend repository..."
if [ -d "$REPO_DIR" ]; then
    echo "Repository exists, updating..."
    cd "$REPO_DIR"
    git fetch origin
    git reset --hard origin/main
else
    echo "Cloning repository..."
    git clone "$FRONTEND_REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"
fi

echo "Repository updated to latest main branch"
echo ""

# Copy Python script to work directory
echo "Preparing scan script..."
cp "$SCRIPT_DIR/appscan_sca.py" "$WORK_DIR/appscan_sca.py"
chmod +x "$WORK_DIR/appscan_sca.py"

# Run the AppScan SCA scan
echo "Starting AppScan SCA scan..."
echo "Application ID: $APPSCAN_APP_ID"
echo "Timeout: $SCAN_TIMEOUT seconds"
echo ""

cd "$REPO_DIR"

python3 "$WORK_DIR/appscan_sca.py" \
    "$APPSCAN_KEY_ID" \
    "$APPSCAN_KEY_SECRET" \
    "$APPSCAN_APP_ID" \
    --timeout "$SCAN_TIMEOUT"

SCAN_EXIT_CODE=$?

if [ $SCAN_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✓ Scan completed successfully!"
    echo "=========================================="
    echo "Report saved to: $REPO_DIR/appscan_sca_report.json"
    echo ""
    
    # Display report summary if jq is available
    if command -v jq &> /dev/null && [ -f "appscan_sca_report.json" ]; then
        echo "Report Summary:"
        echo "---------------"
        jq -r '.[] | select(.IssueType) | "\(.Severity): \(.IssueType) - \(.Location)"' appscan_sca_report.json 2>/dev/null | head -20 || echo "Could not parse report summary"
    fi
else
    echo ""
    echo "=========================================="
    echo "✗ Scan failed with exit code: $SCAN_EXIT_CODE"
    echo "=========================================="
    exit $SCAN_EXIT_CODE
fi
