#!/bin/bash
#
# Witness Container Fix and Restart
#

echo "=========================================="
echo "  Fixing Witness Container Issue"
echo "=========================================="
echo ""

# Stop everything
echo "→ Stopping all services..."
./stop.sh
echo ""

# Check witness logs from previous run (if available)
echo "→ Checking previous witness logs..."
docker logs vleiworklinux1-witness-1 2>&1 | tail -50 || echo "No previous logs available"
echo ""

# Start just the witness service
echo "→ Starting services step-by-step..."
echo "  Starting schema server first..."
docker compose up -d schema
sleep 10
echo ""

echo "  Checking schema health..."
curl -s http://localhost:7723/health || echo "Schema may still be starting"
echo ""

echo "  Starting witness service..."
docker compose up -d witness
echo ""

echo "→ Waiting for witness to initialize (60 seconds)..."
for i in {1..60}; do
    if curl -s http://localhost:5642/oobi >/dev/null 2>&1; then
        echo "✓ Witness is responding!"
        break
    fi
    echo -n "."
    sleep 1
done
echo ""

echo "→ Checking witness status..."
docker ps | grep witness
echo ""

echo "→ Checking witness logs..."
docker logs vleiworklinux1-witness-1 2>&1 | tail -30
echo ""

echo "→ Testing witness endpoints..."
for port in 5642 5643 5644 5645 5646 5647; do
    if curl -s http://localhost:$port/oobi >/dev/null 2>&1; then
        echo "  ✓ Port $port responding"
    else
        echo "  ✗ Port $port not responding"
    fi
done
echo ""

echo "=========================================="
echo "  If witness is healthy, run:"
echo "    ./deploy.sh"
echo ""
echo "  If witness is still failing, run:"
echo "    ./diagnose-witness.sh"
echo "=========================================="
