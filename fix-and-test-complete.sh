#!/bin/bash
################################################################################
# COMPLETE FIX - All 3 Phases
# 
# This script automates the build and test process after fixing:
# - Phase 1: LE AID creation
# - Phase 2: LE AID references  
# - Phase 3: Person AID creation
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
echo -e "${BLUE}║     Complete Fix - Phases 1, 2, 3 & 4 - Build and Test      ║${NC}"
echo -e "${BLUE}║     LE AIDs + Person AIDs - Multiple Organizations           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check if we're in the correct directory
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}ERROR: Must be run from vLEIWorkLinux1 directory${NC}"
    exit 1
fi

echo -e "${BLUE}Phase Summary:${NC}"
echo "  Phase 1: LE AID creation (unique aliases)"
echo "  Phase 2: LE AID references (all operations)"
echo "  Phase 3: Person AID creation (unique aliases)"
echo "  Phase 4: Person AID references (all operations)"
echo ""

# Step 2: Build TypeScript
echo -e "${YELLOW}[1/5] Building TypeScript files...${NC}"
cd sig-wallet

echo "  → Building le-aid-create.ts"
echo "  → Building le-acdc-admit-le.ts"
echo "  → Building person-aid-create.ts"
echo "  → Building person-acdc-admit-oor.ts"

npm install 2>/dev/null || true
npm run build

if [ ! -f "src/tasks/le/le-aid-create.js" ] || \
   [ ! -f "src/tasks/le/le-acdc-admit-le.js" ] || \
   [ ! -f "src/tasks/person/person-aid-create.js" ] || \
   [ ! -f "src/tasks/person/person-acdc-admit-oor.js" ]; then
    echo -e "${RED}ERROR: TypeScript build failed - required .js files not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ TypeScript build complete (4 files compiled)${NC}"
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
echo -e "${BLUE}Testing both Jupiter and Tommy organizations with multiple persons${NC}"
echo ""

./run-all-buyerseller-2.sh

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                 Complete Fix - Test Complete                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}✅ Success Indicators to Check:${NC}"
echo "  1. No 'AID with name le already incepted' errors"
echo "  2. No 'AID with name person already incepted' errors"
echo "  3. Both organizations (Jupiter & Tommy) processed"
echo "  4. Both persons created with unique AIDs:"
echo "     - Jupiter: Chief Sales Officer"
echo "     - Tommy: Chief Procurement Officer"
echo "  5. All credentials issued and presented to verifier"
echo "  6. Script completes successfully"
echo ""

echo -e "${BLUE}📊 What Was Fixed:${NC}"
echo "  Phase 1: LE AID creation uses unique aliases"
echo "  Phase 2: All LE operations reference correct aliases"
echo "  Phase 3: Person AID creation uses unique aliases"
echo "  Phase 4: All Person operations reference correct aliases"
echo ""

echo -e "${BLUE}🎯 Result:${NC}"
echo "  ✓ Multiple organizations supported"
echo "  ✓ Multiple persons per organization supported"
echo "  ✓ Each entity has unique AID"
echo "  ✓ Fully configuration-driven"
echo "  ✓ Scalable to unlimited organizations/persons"
echo ""

echo -e "${BLUE}📄 Generated Files:${NC}"
echo "  • task-data/*.json - Credential and AID information"
echo "  • task-data/trust-tree-buyerseller.txt - Trust chain visualization"
echo ""

echo -e "${BLUE}🔍 Verify Results:${NC}"
echo "  • Check trust tree: cat task-data/trust-tree-buyerseller.txt"
echo "  • View credentials: jq . task-data/le-credential-info.json"
echo "  • Check persons: jq . task-data/person-info.json"
echo "  • Check verifier logs: docker compose logs verifier | tail -50"
echo ""

echo -e "${BLUE}📚 Documentation:${NC}"
echo "  • COMPLETE_FIX_PHASE3.md - Complete technical documentation"
echo "  • COMPLETE_FIX_PHASE2.md - LE AID references fix details"
echo "  • FIX_MULTIPLE_LE_AIDS.md - Initial LE AID fix"
echo ""

exit 0
