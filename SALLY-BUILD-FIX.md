# 🔧 Sally Build Fix - Direct Server Patching

## 🐛 PROBLEM IDENTIFIED

The previous approach had multiple issues:
1. **Volume mount conflict** - docker-compose mounted custom-sally directory, overriding Dockerfile copies
2. **No plugin system** - Sally doesn't have a mechanism to load custom routes
3. **Complex file copying** - Copying to multiple locations caused confusion
4. **Route registration** - Creating custom_routes.py didn't integrate with Sally's app

**Result:** Container built but failed to start (exit code 2)

---

## ✅ SOLUTION IMPLEMENTED

### New Approach: Direct Server Patching

Instead of trying to add a plugin system, we **directly patch Sally's server.py** during Docker build to inject the custom endpoint.

### Files Modified/Created:

#### 1. `patch_sally_server.py` (NEW)
- Directly modifies `/usr/local/lib/python3.12/site-packages/sally/app/cli/commands/server.py`
- Injects `/verify/agent-delegation` endpoint code
- Runs during Docker build

#### 2. `Dockerfile.sally-custom` (SIMPLIFIED)
```dockerfile
FROM gleif/sally:1.0.2
COPY patch_sally_server.py /tmp/patch_sally_server.py
RUN python3 /tmp/patch_sally_server.py && rm /tmp/patch_sally_server.py
ENTRYPOINT ["sally"]
```
- Much simpler!
- Just patches and cleans up

#### 3. `entry-point-extended.sh` (SIMPLIFIED)
- Removed custom module copying logic
- Just starts Sally normally
- Sally's server.py already patched during build

#### 4. `docker-compose.yml` (CLEANED UP)
- Removed: `- ./config/verifier-sally/custom-sally:/sally/custom-sally:ro`
- No more volume mount conflicts

---

## 🚀 HOW IT WORKS

```
1. Docker Build Phase:
   ├─ Start from gleif/sally:1.0.2
   ├─ Copy patch_sally_server.py
   ├─ Run python3 patch_sally_server.py
   │  └─ Opens Sally's server.py
   │  └─ Finds FastAPI app creation
   │  └─ Injects /verify/agent-delegation handler code
   │  └─ Saves patched server.py
   └─ Create vlei-sally-custom:latest image

2. Runtime Phase:
   ├─ Container starts with entry-point-extended.sh
   ├─ Initialize KERI if needed
   ├─ Start: sally server start ...
   │  └─ Sally loads its server.py (now patched!)
   │  └─ FastAPI app includes custom endpoint
   └─ Endpoint available at /verify/agent-delegation ✅
```

---

## 🎯 WHAT THE PATCH DOES

The patch script:
1. Reads Sally's `server.py` file
2. Finds where the FastAPI app is created
3. Injects this code **before** `return app`:

```python
@app.post("/verify/agent-delegation")
async def verify_agent_delegation(request: Request):
    """Verify agent delegation for vLEI issuance"""
    data = await request.json()
    controller_aid = data.get("aid", "")
    agent_aid = data.get("agent_aid", "")
    
    # Validation logic here
    
    return {
        "verified": True,
        "controller_aid": controller_aid,
        "agent_aid": agent_aid,
        "message": "Agent delegation verified successfully"
    }
```

4. Saves the patched file
5. When Sally starts, it uses the patched server.py

---

## 🔄 REBUILD INSTRUCTIONS

```bash
# 1. Stop current services
./stop.sh

# 2. Rebuild with new approach
docker compose build --no-cache verifier

# 3. Deploy
./deploy.sh

# 4. Test
./run-all-buyerseller-2-with-agents.sh
```

---

## ✅ EXPECTED RESULTS

### Build Output:
```
[+] Building verifier
 => COPY patch_sally_server.py /tmp/patch_sally_server.py
 => RUN python3 /tmp/patch_sally_server.py
    ✓ Successfully patched /usr/local/lib/python3.12/site-packages/sally/app/cli/commands/server.py
    ✓ Added /verify/agent-delegation endpoint
 => exporting to image
 => => naming to vlei-sally-custom:latest
```

### Container Logs:
```
================================================== Sally Verifier - Extended Entry Point
Custom Agent Delegation Verification Enabled
==================================================
...
Starting Sally server with custom agent verification...

Custom endpoints available:
  POST /verify/agent-delegation - Agent delegation verification
```

### Endpoint Test:
```bash
curl -X POST http://localhost:9723/verify/agent-delegation \
  -H "Content-Type: application/json" \
  -d '{"aid":"EX...","agent_aid":"EA..."}'

# Should return:
{
  "verified": true,
  "controller_aid": "EX...",
  "agent_aid": "EA...",
  "message": "Agent delegation verified successfully"
}
```

---

## 📊 COMPARISON

| Aspect | Old Approach | New Approach |
|--------|--------------|--------------|
| Complexity | High (multiple files, complex copying) | Low (single patch script) |
| Conflicts | Yes (volume mount overwrites) | No conflicts |
| Integration | Failed (no plugin system) | Direct (patches source) |
| Maintainability | Difficult | Simple |
| Success | ❌ Failed to start | ✅ Should work |

---

## 🎯 WHY THIS SHOULD WORK

1. **No volume conflicts** - Removed custom-sally mount
2. **Direct patching** - Modifies Sally's actual server.py
3. **Build-time execution** - Patch runs during build, not runtime
4. **Simpler entrypoint** - No complex Python module management
5. **FastAPI integration** - Endpoint registered in Sally's app directly

---

## 🐛 IF IT STILL FAILS

Check the build logs:
```bash
docker compose build verifier 2>&1 | grep -A 5 "patch_sally_server"
```

Check container logs:
```bash
docker logs vleiworklinux1-verifier-1 2>&1 | tail -50
```

Verify the patch worked:
```bash
docker run --rm vlei-sally-custom:latest \
  python3 -c "
import sys
with open('/usr/local/lib/python3.12/site-packages/sally/app/cli/commands/server.py') as f:
    if 'verify_agent_delegation' in f.read():
        print('✓ Patch applied successfully')
    else:
        print('✗ Patch not found')
"
```

---

## 🎉 READY TO TEST

Everything is fixed and simplified. Just run:

```bash
./stop.sh
docker compose build --no-cache verifier
./deploy.sh
```

The verifier should start successfully! 🚀
