#!/bin/bash
set -e

echo "=========================================="
echo "DEEP AGENT DELEGATION VERIFICATION"
echo "=========================================="
echo ""

AGENT_NAME="${1:-jupiterSellerAgent}"
OOR_HOLDER_NAME="${2:-Jupiter_Chief_Sales_Officer}"
ENV="${3:-docker}"

# TWO PASSCODES needed!
AGENT_PASSCODE="AgentPass123"
OOR_PASSCODE="0ADckowyGuNwtJUPLeRqZvTp"

echo "Configuration:"
echo "  Agent: ${AGENT_NAME}"
echo "  OOR Holder: ${OOR_HOLDER_NAME}"
echo "  Agent Passcode: ${AGENT_PASSCODE}"
echo "  OOR Passcode: ${OOR_PASSCODE}"
echo ""

docker compose exec -T tsx-shell tsx sig-wallet/src/tasks/agent/agent-verify-delegation-deep.ts \
  "${ENV}" \
  "${AGENT_PASSCODE}" \
  "${OOR_PASSCODE}" \
  "${AGENT_NAME}" \
  "${OOR_HOLDER_NAME}"

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ DEEP VERIFICATION PASSED!"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "❌ DEEP VERIFICATION FAILED"
    echo "=========================================="
    exit 1
fi
