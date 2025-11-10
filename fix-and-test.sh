#!/bin/bash
################################################################################
# QUICK FIX SCRIPT - Multiple LE AID Creation Issue
# 
# This script automates the build and test process after fixing the
# multiple LE AID creation issue.
#
# Date: November 10, 2025
################################################################################

set -e  # Exit on error

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Multiple LE AID Fix - Build and Test Script         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check if we're in the correct directory
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}ERROR: Must be run from vLEIWorkLinux1 directory${NC}"
    exit 1
fi

# Step 2: Build TypeScript
echo -e "${YELLOW}[1/5] Building TypeScript files...${NC}"
cd sig-wallet
npm install 2>/dev/null || true
npm run build

if [ ! -f "src/tasks/le/le-aid-create.js" ]; then
    echo -e "${RED}ERROR: TypeScript build failed - le-aid-create.js not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ TypeScript build complete${NC}"
echo ""

# Step 3: Return to main directory
cd ..

# Step 4: Stop and clean environment
echo -e "${YELLOW}[2/5] Stopping and cleaning environment...${NC}"
./stop.sh
echo -e "${GREEN}✓ Environment stopped${NC}"
echo ""

# Step 5: Rebuild Docker images
echo -e "${YELLOW}[3/5] Rebuilding Docker images...${NC}"
docker compose build
echo -e "${GREEN}✓ Docker images rebuilt${NC}"
echo ""

# Step 6: Deploy services
echo -e "${YELLOW}[4/5] Deploying services...${NC}"
./deploy.sh
echo -e "${GREEN}✓ Services deployed${NC}"
echo ""

# Step 7: Run the full test
echo -e "${YELLOW}[5/5] Running full credential issuance test...${NC}"
echo -e "${BLUE}This will test both Jupiter and Tommy organizations${NC}"
echo ""

./run-all-buyerseller-2.sh

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Build and Test Complete                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}✅ Success Indicators to Check:${NC}"
echo "  1. No 'AID with name le already incepted' errors"
echo "  2. Both organizations (Jupiter & Tommy) processed"
echo "  3. Unique LE AID prefixes for each organization"
echo "  4. All credentials issued and presented to verifier"
echo ""

echo -e "${BLUE}📄 Generated Files:${NC}"
echo "  • task-data/*.json - Credential and AID information"
echo "  • task-data/trust-tree-buyerseller.txt - Trust chain visualization"
echo ""

echo -e "${BLUE}🔍 Verify Results:${NC}"
echo "  • Check trust tree: cat task-data/trust-tree-buyerseller.txt"
echo "  • View credentials: jq . task-data/le-credential-info.json"
echo "  • Check verifier logs: docker compose logs verifier | tail -50"
echo ""

exit 0
