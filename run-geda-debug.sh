#!/bin/bash
# run-geda-debug.sh - Run the debug version to see WHERE it hangs

echo "================================================"
echo "Running GEDA AID Creation with Debug Output"
echo "================================================"
echo ""

source ./task-scripts/workshop-env-vars.sh

echo "Running debug version with detailed logging..."
echo "Watch for where it stops to identify the hang point"
echo ""

timeout 60s docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh geda/geda-aid-create-debug.ts \
    'docker' \
    "${GEDA_SALT}" \
    "/task-data" || {
    EXIT_CODE=$?
    echo ""
    echo "================================================"
    if [ $EXIT_CODE -eq 124 ]; then
        echo "TIMEOUT after 60 seconds"
        echo ""
        echo "The last line printed above shows WHERE the hang occurred:"
        echo "  - If it stops at 'Step 1': Problem connecting to KERIA"
        echo "  - If it stops at 'Step 2': Problem creating AID"
        echo "  - If it stops at 'Step 3': Problem writing files"
    else
        echo "ERROR occurred (exit code: $EXIT_CODE)"
    fi
    echo "================================================"
    exit 1
}

echo ""
echo "✓ Debug run completed successfully!"
