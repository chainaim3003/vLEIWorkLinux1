# Agent Delegation Verification Fix

## Problem Summary

The `run-all-buyerseller-2-with-agents.sh` script fails at agent delegation verification:

```
Calling Sally verifier at http://vlei-verification:9723/verify/agent-delegation
✗ Failed to call Sally verifier
  Error: TypeError: fetch failed
```

## Root Cause

1. **Code expects**: `http://vlei-verification:9723/verify/agent-delegation`
2. **Docker has**: Only standard Sally verifier service named `verifier` (no agent delegation endpoint)
3. **Custom verifier exists** but is NOT deployed: `Dockerfile.verification-keri` + `verification_service_keri.py`

## The Solution

Add the custom KERI agent delegation verification service to `docker-compose.yml`.

### Step 1: Edit docker-compose.yml

Add this service definition **after** the existing `verifier:` service (around line 140):

```yaml
  # KERI-enabled Agent Delegation Verification Service
  vlei-verification:
    build:
      context: ./config/verifier-sally
      dockerfile: Dockerfile.verification-keri
      no_cache: true
    container_name: vlei_verification
    hostname: vlei-verification
    stop_grace_period: 1s
    environment:
      PYTHONUNBUFFERED: 1
      PYTHONIOENCODING: UTF-8
      PYTHONWARNINGS: 'ignore::SyntaxWarning'
      KERIA_URL: http://keria:3902
    healthcheck:
      test: [ "CMD", "wget", "--spider", "--tries=1", "--no-verbose", "http://127.0.0.1:9723/health" ]
      interval: 3s
      timeout: 3s
      retries: 4
      start_period: 2s
    ports:
      - "9724:9723"
    depends_on:
      keria:
        condition: service_healthy
      schema:
        condition: service_healthy
```

### Step 2: Copy to WSL and Deploy

In Windows (PowerShell):
```powershell
# Copy the updated docker-compose.yml to WSL
wsl cp /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/docker-compose.yml ~/projects/vLEIWorkLinux1/
```

In WSL:
```bash
cd ~/projects/vLEIWorkLinux1

# Stop existing services
./stop.sh

# Build with no cache
docker compose build --no-cache

# Deploy
./deploy.sh
```

### Step 3: Verify the Service

```bash
# Check if vlei-verification service is running
docker ps | grep vlei_verification

# Test the health endpoint
curl http://localhost:9724/health

# Expected response:
# {
#   "status": "healthy",
#   "service": "agent-delegation-verifier-keri",
#   "version": "2.0.0",
#   "keria_status": "connected",
#   "keria_url": "http://keria:3902"
# }
```

### Step 4: Run the Full Workflow

```bash
./run-all-buyerseller-2-with-agents.sh
```

The agent delegation verification should now succeed!

## What This Custom Verifier Does

The `vlei-verification` service (`verification_service_keri.py`):

1. **Queries KERIA** for Agent and OOR Holder KELs
2. **Verifies KEL delegation**: Checks agent's `icp` event has `di` (delegator) field pointing to OOR holder
3. **Verifies delegation seal**: Confirms OOR holder's KEL contains seal anchoring agent's inception
4. **Optional**: Can verify full credential chains (OOR → OOR_AUTH → LE → QVI → GEDA)

## Service Architecture

```
┌─────────────────────────────────────────────────┐
│  docker-compose.yml                             │
├─────────────────────────────────────────────────┤
│                                                 │
│  verifier (port 9723)                           │
│  └─ Standard Sally (credential presentation)    │
│                                                 │
│  vlei-verification (port 9724 → 9723)           │
│  └─ Custom KERI verifier (agent delegation)     │
│     - Endpoint: /verify/agent-delegation        │
│     - KEL-based verification                    │
│     - Queries KERIA for live KEL data           │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Files Involved

### 1. docker-compose.yml (NEEDS UPDATE)
Location: `C:\SATHYA\CHAINAIM3003\mcp-servers\stellarboston\vLEI1\vLEIWorkLinux1\docker-compose.yml`
Action: Add `vlei-verification` service

### 2. Dockerfile.verification-keri (EXISTS)
Location: `config/verifier-sally/Dockerfile.verification-keri`
Status: ✓ Already created

### 3. verification_service_keri.py (EXISTS)  
Location: `config/verifier-sally/verification_service_keri.py`
Status: ✓ Already created  
Purpose: FastAPI service with `/verify/agent-delegation` endpoint

### 4. agent-verify-delegation.ts (CORRECT)
Location: `sig-wallet/src/tasks/agent/agent-verify-delegation.ts`
Status: ✓ Calls correct endpoint
Endpoint: `http://vlei-verification:9723/verify/agent-delegation`

## Troubleshooting

### Issue: "vlei_verification container not found"
```bash
docker compose build vlei-verification --no-cache
docker compose up -d vlei-verification
```

### Issue: "Connection refused to vlei-verification"
```bash
# Check if service is running
docker logs vlei_verification

# Check KERIA connectivity
docker exec vlei_verification wget -O- http://keria:3902/spec.yaml
```

### Issue: "Healthcheck failing"
```bash
# Check service logs
docker logs vlei_verification

# Manual health check
curl http://localhost:9724/health
```

## Alternative Quick Fix (If Above Doesn't Work)

If you can't edit docker-compose.yml, you can update the TypeScript code to call the existing `verifier` service (though it won't have proper agent delegation verification):

```typescript
// In agent-verify-delegation.ts, change:
const sallyUrl = 'http://vlei-verification:9723/verify/agent-delegation';
// To:
const sallyUrl = 'http://verifier:9723/verify';  // Standard Sally endpoint
```

But this won't give you proper KEL-based delegation verification - just basic verification.

## Summary

✅ **Recommended Solution**: Add `vlei-verification` service to docker-compose.yml  
✅ **Benefit**: Full KEL-based agent delegation verification  
✅ **Status**: All code exists, just needs deployment configuration  

---

**After making these changes, your agent delegation workflow will work end-to-end!**
