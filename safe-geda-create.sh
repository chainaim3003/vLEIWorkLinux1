#!/bin/bash
# safe-geda-create.sh - Run geda-aid-create only when KERIA is ready

set -e

echo "================================================"
echo "Safe GEDA AID Creation"
echo "================================================"
echo ""

echo "Checking prerequisites..."
echo ""

# Check tsx-shell
if ! docker ps --filter "name=tsx_shell" --format "{{.Names}}" | grep -q "tsx_shell"; then
    echo "✗ tsx-shell container is not running"
    echo "  Run: ./deploy.sh"
    exit 1
fi
echo "✓ tsx-shell container is running"

# Check KERIA container
if ! docker ps --filter "name=keria" --format "{{.Names}}" | grep -q "keria"; then
    echo "✗ KERIA container is not running"
    echo "  Run: ./deploy.sh"
    exit 1
fi
echo "✓ KERIA container is running"

# Check KERIA health from host
echo ""
echo "Waiting for KERIA to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0
KERIA_READY=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s -f -m 2 http://127.0.0.1:3902/spec.yaml >/dev/null 2>&1; then
        KERIA_READY=true
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "  Waiting for KERIA... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ "$KERIA_READY" = false ]; then
    echo "✗ KERIA is not responding after $MAX_RETRIES attempts"
    echo ""
    echo "Checking KERIA logs:"
    docker logs --tail 30 $(docker ps -q --filter "name=keria")
    echo ""
    echo "Try restarting KERIA:"
    echo "  docker restart \$(docker ps -q --filter 'name=keria')"
    exit 1
fi

echo "✓ KERIA is healthy and responding"

# Check KERIA network connectivity from tsx-shell
echo ""
echo "Checking KERIA network connectivity..."
if ! docker exec tsx_shell sh -c "curl -s -f -m 5 http://keria:3901 >/dev/null 2>&1"; then
    echo "✗ tsx-shell cannot reach KERIA on Docker network"
    echo "  This is a Docker networking issue"
    echo ""
    echo "Try: ./stop.sh && ./deploy.sh"
    exit 1
fi
echo "✓ tsx-shell can reach KERIA"

# All checks passed, run the script
echo ""
echo "================================================"
echo "All prerequisites met! Running geda-aid-create.sh"
echo "================================================"
echo ""

./task-scripts/geda/geda-aid-create.sh

echo ""
echo "================================================"
echo "✓ GEDA AID Created Successfully!"
echo "================================================"
