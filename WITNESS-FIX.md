# WITNESS CONTAINER FIX

## Problem
```
✘ Container vleiworklinux1-witness-1   Error
dependency failed to start: container vleiworklinux1-witness-1 is unhealthy
```

## Root Cause
The witness service runs **6 separate witness nodes** simultaneously:
- wan (port 5642)
- wil (port 5643)  
- wes (port 5644)
- wit (port 5645)
- wub (port 5646)
- wyz (port 5647)

The health check was starting too early (2 seconds) before all witnesses could initialize.

## Solution Applied

### Changed in docker-compose.yml:
```yaml
# BEFORE:
healthcheck:
  <<: *healthcheck  # start_period: 2s

# AFTER:
healthcheck:
  interval: 3s
  timeout: 3s
  retries: 4
  start_period: 10s  # ← Increased from 2s to 10s
```

This gives the witness service adequate time to:
1. Initialize the Python environment
2. Start all 6 witness nodes
3. Bind to all 6 ports
4. Begin responding to health check requests

## Deployment Instructions

### In WSL:

```bash
cd ~/projects/vLEIWorkLinux1

# Copy updated docker-compose.yml
cp /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/docker-compose.yml .

# Copy diagnostic scripts
cp /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/fix-witness.sh .
cp /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/diagnose-witness.sh .

# Fix permissions
dos2unix fix-witness.sh diagnose-witness.sh
chmod +x fix-witness.sh diagnose-witness.sh

# Deploy
./stop.sh
docker compose build --no-cache  # If needed
./deploy.sh
```

## Verification Steps

### 1. Check all services are healthy:
```bash
docker ps
```

Expected: All containers showing "healthy" status

### 2. Test witness endpoints:
```bash
for port in 5642 5643 5644 5645 5646 5647; do
  curl -s http://localhost:$port/oobi && echo " ✓ Port $port OK" || echo " ✗ Port $port FAIL"
done
```

Expected: All 6 ports responding

### 3. Check witness logs:
```bash
docker logs vleiworklinux1-witness-1 | tail -50
```

Expected: Should see witness nodes starting successfully

## Troubleshooting

### If witness still fails:

#### 1. Check for port conflicts
```bash
sudo netstat -tlnp | grep -E "564[2-7]"
```
If ports are in use, stop conflicting services.

#### 2. Check witness logs
```bash
docker logs vleiworklinux1-witness-1
```
Look for error messages.

#### 3. Try manual start
```bash
./fix-witness.sh
```
This script starts services step-by-step and provides detailed diagnostics.

#### 4. Run diagnostics
```bash
./diagnose-witness.sh
```
Comprehensive diagnostic information.

#### 5. Check config files
```bash
ls -la ./config/witnesses/
```
Ensure all 6 witness config files exist:
- wan.json
- wil.json
- wes.json
- wit.json
- wub.json
- wyz.json

### Common Issues:

**Issue: "Address already in use"**
```bash
# Find and kill process on conflicting port
sudo lsof -i :5642
sudo kill <PID>
```

**Issue: "Permission denied" on config files**
```bash
chmod 644 ./config/witnesses/*.json
```

**Issue: Witness takes too long to start**
- Increase `start_period` further to 15s or 20s in docker-compose.yml

## Files Modified

| File | Change | Purpose |
|------|--------|---------|
| docker-compose.yml | Increased witness `start_period` to 10s | Give witness time to initialize |
| fix-witness.sh | New diagnostic script | Step-by-step witness startup |
| diagnose-witness.sh | New diagnostic script | Comprehensive witness diagnostics |

## Expected Result

After this fix, all services should start successfully:

```bash
./deploy.sh
```

Expected output:
```
✔ Container vleiworklinux1-schema-1    Healthy
✔ Container vleiworklinux1-witness-1   Healthy
✔ Container vleiworklinux1-verifier-1  Healthy
✔ Container vleiworklinux1-keria-1     Healthy
✔ Container vlei_verification          Healthy
```

Then run the full workflow:
```bash
./run-all-buyerseller-2-with-agents.sh
```

## Summary

**Problem:** Witness container failing because health check started too early  
**Solution:** Increased `start_period` from 2s to 10s  
**Result:** All 6 witness nodes have time to initialize before health check runs

---

**Next:** Run `./deploy.sh` to test the fix! 🚀
