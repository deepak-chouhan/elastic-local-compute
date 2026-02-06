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