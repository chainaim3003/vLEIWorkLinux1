# Hang Investigation - Quick Reference

## You Were Right!

You already ran `./stop.sh`, `docker compose build`, and `./deploy.sh` - containers ARE running.

The hang is NOT about missing containers. It's about **KERIA initialization or connectivity**.

## The Real Problem

The TypeScript code tries to connect to KERIA at `http://keria:3901` and either:
1. **KERIA is still starting** (needs 10-30 seconds after container starts)
2. **Network issue** (tsx-shell can't reach KERIA)
3. **KERIA crashed** or is unhealthy

## What to Do

### STEP 1: Diagnose the problem
```bash
chmod +x diagnose-hang.sh
./diagnose-hang.sh
```

This shows you EXACTLY what's wrong:
- Are containers running?
- Is KERIA accessible from host?
- Is KERIA accessible from tsx-shell?
- KERIA error logs

### STEP 2: Use the safe wrapper (RECOMMENDED)
```bash
chmod +x safe-geda-create.sh
./safe-geda-create.sh
```

This automatically:
- Waits up to 60 seconds for KERIA to be ready
- Tests all prerequisites
- Only runs when everything is healthy
- Shows clear error messages

### STEP 3: Or test with timeout
```bash
chmod +x test-geda-verbose.sh
./test-geda-verbose.sh
```

This runs with:
- 30-second timeout (won't hang forever)
- Step-by-step progress
- Shows WHERE it fails

## Most Likely Fix

**KERIA just needs more time!**

```bash
# Wait 20 seconds
sleep 20

# Check if KERIA is ready
curl http://127.0.0.1:3902/spec.yaml

# If that works, KERIA is ready. Try again:
./safe-geda-create.sh
```

## If KERIA Still Not Ready

```bash
# Restart just KERIA
docker restart $(docker ps -q --filter "name=keria")

# Wait and watch logs
docker logs -f $(docker ps -q --filter "name=keria")
# Look for: "serving on port 3902"

# Once you see that, KERIA is ready
./safe-geda-create.sh
```

## Quick Commands

```bash
# Check KERIA status
curl http://127.0.0.1:3902/spec.yaml

# Check KERIA logs
docker logs $(docker ps -q --filter "name=keria")

# Restart KERIA only
docker restart $(docker ps -q --filter "name=keria")

# Check from inside tsx-shell
docker exec tsx_shell curl -s http://keria:3901
```

## Summary

1. **Run** `./diagnose-hang.sh` to see what's wrong
2. **Use** `./safe-geda-create.sh` going forward (it waits for KERIA)
3. **Most likely**: Just wait 20-30 seconds for KERIA to finish starting

Your containers are fine. KERIA just takes time to initialize!
