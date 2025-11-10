#!/bin/bash
# Test script to diagnose task-data write issues

echo "Testing task-data write permissions..."
echo ""

# Test 1: Write from host
echo "Test 1: Writing from host..."
echo "test from host" > ./task-data/test-host.txt
ls -la ./task-data/
echo ""

# Test 2: Write from tsx-shell container
echo "Test 2: Writing from tsx-shell container..."
docker compose exec tsx-shell sh -c "echo 'test from tsx-shell' > /task-data/test-tsx.txt"
docker compose exec tsx-shell ls -la /task-data/
echo ""

# Test 3: Check if files exist on host
echo "Test 3: Checking host filesystem..."
ls -la ./task-data/
echo ""

# Test 4: Test Node.js fs.writeFile from tsx-shell
echo "Test 4: Testing Node.js fs.writeFile..."
docker compose exec tsx-shell node -e "
const fs = require('fs');
fs.writeFileSync('/task-data/test-node.txt', 'test from node');
console.log('Node.js write completed');
"
docker compose exec tsx-shell ls -la /task-data/
echo ""

echo "Test 5: Checking host filesystem again..."
ls -la ./task-data/
