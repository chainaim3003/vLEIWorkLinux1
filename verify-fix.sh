#!/bin/bash
################################################################################
# verify-fix.sh - Verify that file persistence fix is working
################################################################################

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}====================================="
echo "   File Persistence Verification"
echo "=====================================${NC}"
echo ""

# Check 1: Docker is running
echo -e "${YELLOW}Check 1: Docker daemon${NC}"
if docker info > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker is running${NC}"
else
    echo -e "${RED}✗ Docker is not running${NC}"
    echo "Please start Docker Desktop and try again"
    exit 1
fi
echo ""

# Check 2: tsx-shell image exists
echo -e "${YELLOW}Check 2: tsx-shell image${NC}"
if docker images | grep -q "gleif/wkshp-tsx-shell"; then
    IMAGE_DATE=$(docker images gleif/wkshp-tsx-shell:latest --format "{{.CreatedAt}}")
    echo -e "${GREEN}✓ tsx-shell image exists${NC}"
    echo "  Created: $IMAGE_DATE"
else
    echo -e "${RED}✗ tsx-shell image not found${NC}"
    echo "Run: docker compose build tsx-shell"
    exit 1
fi
echo ""

# Check 3: Containers are running
echo -e "${YELLOW}Check 3: Running containers${NC}"
RUNNING=$(docker compose ps --format json 2>/dev/null | grep -c '"State":"running"' || echo "0")
if [ "$RUNNING" -gt 0 ]; then
    echo -e "${GREEN}✓ $RUNNING containers running${NC}"
    docker compose ps --format "table {{.Name}}\t{{.Status}}"
else
    echo -e "${YELLOW}⚠ No containers running${NC}"
    echo "Run: ./deploy.sh"
fi
echo ""

# Check 4: task-data directory
echo -e "${YELLOW}Check 4: task-data directory${NC}"
if [ -d "./task-data" ]; then
    echo -e "${GREEN}✓ task-data exists${NC}"
    FILE_COUNT=$(ls -1 ./task-data/ 2>/dev/null | grep -v "^\.gitignore$" | wc -l)
    echo "  Files: $FILE_COUNT"
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo ""
        echo "  Current files:"
        ls -lh ./task-data/ | grep -v "^total" | grep -v "\.gitignore"
    fi
else
    echo -e "${RED}✗ task-data directory not found${NC}"
    exit 1
fi
echo ""

# Check 5: Can write to task-data from container
echo -e "${YELLOW}Check 5: Container write test${NC}"
if [ "$RUNNING" -gt 0 ]; then
    TEST_FILE="test-$(date +%s).txt"
    if docker compose exec tsx-shell sh -c "echo 'test' > /task-data/$TEST_FILE" 2>/dev/null; then
        sleep 1
        if [ -f "./task-data/$TEST_FILE" ]; then
            echo -e "${GREEN}✓ Container can write to task-data${NC}"
            echo -e "${GREEN}✓ Files sync to host filesystem${NC}"
            rm -f "./task-data/$TEST_FILE"
        else
            echo -e "${RED}✗ Files don't sync to host${NC}"
            echo "This indicates a volume mount issue"
        fi
    else
        echo -e "${YELLOW}⚠ Cannot test (container not ready)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Skipped (no containers running)${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}====================================="
echo "   Verification Summary"
echo "=====================================${NC}"
echo ""

if [ "$RUNNING" -gt 0 ] && [ -f "./task-data/$TEST_FILE" ] 2>/dev/null; then
    rm -f "./task-data/$TEST_FILE"
fi

if docker images | grep -q "gleif/wkshp-tsx-shell" && docker info > /dev/null 2>&1; then
    echo -e "${GREEN}✓ System is ready${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. If containers not running: ./deploy.sh"
    echo "  2. Test file persistence: ./task-scripts/geda/geda-aid-create.sh"
    echo "  3. Check files: ls -la ./task-data/"
    echo "  4. Run full workflow: ./run-all.sh"
else
    echo -e "${RED}✗ System needs attention${NC}"
    echo ""
    echo "Required steps:"
    if ! docker info > /dev/null 2>&1; then
        echo "  1. Start Docker Desktop"
    fi
    if ! docker images | grep -q "gleif/wkshp-tsx-shell"; then
        echo "  2. Build image: docker compose build tsx-shell"
    fi
    echo "  3. Deploy: ./deploy.sh"
fi
echo ""
