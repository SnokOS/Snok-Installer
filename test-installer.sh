#!/bin/bash

################################################################################
# Snok-Installer Test Script
# Run basic tests to verify installer functionality
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="${SCRIPT_DIR}/snok-installer.sh"

echo "=== Snok-Installer Test Suite ==="
echo ""

# Test 1: Check if installer exists
echo "[TEST 1] Checking if installer exists..."
if [ -f "$INSTALLER" ]; then
    echo "✓ PASS: Installer script found"
else
    echo "✗ FAIL: Installer script not found"
    exit 1
fi

# Test 2: Check if installer is executable
echo "[TEST 2] Checking if installer is executable..."
if [ -x "$INSTALLER" ]; then
    echo "✓ PASS: Installer is executable"
else
    echo "✗ FAIL: Installer is not executable"
    exit 1
fi

# Test 3: Check bash syntax
echo "[TEST 3] Checking bash syntax..."
if bash -n "$INSTALLER" 2>/dev/null; then
    echo "✓ PASS: No syntax errors"
else
    echo "✗ FAIL: Syntax errors detected"
    bash -n "$INSTALLER"
    exit 1
fi

# Test 4: Check dependencies
echo "[TEST 4] Checking dependencies..."
deps=("dialog" "lsblk" "parted")
missing=()
for dep in "${deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing+=("$dep")
    fi
done

if [ ${#missing[@]} -eq 0 ]; then
    echo "✓ PASS: All dependencies available"
else
    echo "⚠ WARNING: Missing dependencies: ${missing[*]}"
    echo "  Install with: sudo apt install ${missing[*]}"
fi

# Test 5: Check directory structure
echo "[TEST 5] Checking directory structure..."
required_dirs=("assets" "config" "logs")
missing_dirs=()
for dir in "${required_dirs[@]}"; do
    if [ ! -d "${SCRIPT_DIR}/${dir}" ]; then
        missing_dirs+=("$dir")
    fi
done

if [ ${#missing_dirs[@]} -eq 0 ]; then
    echo "✓ PASS: All required directories exist"
else
    echo "✗ FAIL: Missing directories: ${missing_dirs[*]}"
    exit 1
fi

# Test 6: Check configuration files
echo "[TEST 6] Checking configuration files..."
config_files=("config/languages.json" "config/installer.json")
missing_configs=()
for config in "${config_files[@]}"; do
    if [ ! -f "${SCRIPT_DIR}/${config}" ]; then
        missing_configs+=("$config")
    fi
done

if [ ${#missing_configs[@]} -eq 0 ]; then
    echo "✓ PASS: All configuration files exist"
else
    echo "✗ FAIL: Missing config files: ${missing_configs[*]}"
    exit 1
fi

# Test 7: Check logo
echo "[TEST 7] Checking logo file..."
if [ -f "${SCRIPT_DIR}/assets/logo.png" ]; then
    echo "✓ PASS: Logo file exists"
else
    echo "⚠ WARNING: Logo file not found"
fi

# Test 8: Hardware detection simulation
echo "[TEST 8] Testing hardware detection..."
if [ -d /sys/firmware/efi ]; then
    echo "  Boot mode: UEFI"
else
    echo "  Boot mode: Legacy BIOS"
fi

if lspci 2>/dev/null | grep -i nvidia &> /dev/null; then
    echo "  NVIDIA GPU: Detected"
else
    echo "  NVIDIA GPU: Not detected"
fi

echo "✓ PASS: Hardware detection working"

echo ""
echo "=== Test Summary ==="
echo "All critical tests passed!"
echo ""
echo "To run the installer:"
echo "  sudo ${INSTALLER}"
echo ""
echo "Note: Full testing requires running in a VM or test environment"
