#!/bin/bash -e

#---------------------------------------------------------------------------------
# title         : setup.sh
# description   : This script sets up everything required to run the project.
# author        : Deepak Chouhan
#---------------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_banner() {
    local msg="$*"

    echo -e "${GREEN}========================================${NC}"
    echo -e ""
    echo -e "${GREEN} ${msg}${NC}"
    echo -e ""
    echo -e "${GREEN}========================================${NC}"
    echo -e ""
}


PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_banner "Elastic Local Compute"

# Check for macOS 
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}ERROR: This setup script is designed for macOS${NC}"
    echo -e "- Please refer to manual setup instruction for other platforms"
    exit 1
fi

echo -e "${GREEN}✔ Running on macOS${NC}"

# Check architecture
ARCH=$(uname -m)
echo -e "${GREEN}✔ Architecture: ${ARCH}${NC}"

# Check dependencies
echo ""
echo -e "${BLUE}Checking dependencies...${NC}"

# Brew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}✗ Homebrew not found${NC}"
    echo -e "- Install from: https://brew.sh/"
    exit 1
fi
echo -e "${GREEN}✔ Homebrew installed${NC}"

# Python
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠ Python 3 not found, installing...${NC}"
    brew install python@3.11
fi
PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}✓ $PYTHON_VERSION installed${NC}"

# Node.JS
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠ Node.js not found, installing...${NC}"
    brew install node
fi
NODE_VERSION=$(node --version)
echo -e "${GREEN}✓ Node.JS $NODE_VERSION installed${NC}"

# Libvirt
if ! command -v virsh &> /dev/null; then
    echo -e "${YELLOW}⚠ libvirt not found, installing...${NC}"
    brew install libvirt
fi
echo -e "${GREEN}✓ Libvirt installed${NC}"

# QEMU
if ! command -v qemu-system-aarch64 &> /dev/null; then
    echo -e "${YELLOW}⚠ QEMU not found, installing...${NC}"
    brew install qemu
fi
echo -e "${GREEN}✓ QEMU installed${NC}"

# genisoimage (for cloud-init)
if ! command -v mkisofs &> /dev/null && ! command -v genisoimage &> /dev/null; then
    echo -e "${YELLOW}⚠ mkisofs/genisoimage not found, installing cdrtools...${NC}"
    brew install cdrtools
fi
if command -v mkisofs &> /dev/null; then
    echo -e "${GREEN}✓ mkisofs installed${NC}"
elif command -v genisoimage &> /dev/null; then
    echo -e "${GREEN}✓ genisoimage installed${NC}"
else
    echo -e "${RED}✗ ISO creation tool not found${NC}"
    exit 1
fi