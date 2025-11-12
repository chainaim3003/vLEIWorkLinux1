# HEALTH CHECK FIX FOR vlei_verification

## Problem
The `vlei_verification` container was failing health checks because:
- The base image `python:3.12-slim` doesn't include `wget`
- The health check was configured to use `wget`

## Solution Applied

### 1. Updated Dockerfile.verification-keri
**Added curl installation:**
```dockerfile
# Install system dependencies (curl for health checks)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*
```

### 2. Updated docker-compose.yml
**Changed health check from `wget` to `curl`:**
```yaml
healthcheck:
  test: [ "CMD", "curl", "-f", "http://127.0.0.1:9723/health" ]
```

## Deployment Instructions

### In WSL Terminal:

```bash
cd ~/projects/vLEIWorkLinux1

# Copy updated files from Windows
cp /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/docker-compose.yml .
cp /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/config/verifier-sally/Dockerfile.verification-keri ./config/verifier-sally/

# Stop existing services
./stop.sh

# Rebuild with the fix
docker compose build --no-cache vlei-verification

# Or rebuild everything
docker compose build --no-cache

# Deploy
./deploy.sh
```

### Expected Output:
```
✔ Container vlei_verification  Healthy
```

### Verify It's Working:
```bash
# Check container status
docker ps | grep vlei_verification

# Check logs
docker logs vlei_verification

# Test health endpoint
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

## Files Changed

1. ✅ `config/verifier-sally/Dockerfile.verification-keri` - Added curl
2. ✅ `docker-compose.yml` - Changed health check to use curl

## Next Steps

After successful deployment:
```bash
./run-all-buyerseller-2-with-agents.sh
```

The agent delegation verification should now complete successfully!
