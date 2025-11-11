# 🚀 Sally Custom Build - Deployment Checklist

## ✅ CHANGES COMPLETED

### 1. docker-compose.yml Updated
**Changed from:**
```yaml
verifier:
  stop_grace_period: 1s
  <<: *sally-image  # Pre-built gleif/sally:1.0.2
```

**Changed to:**
```yaml
verifier:
  stop_grace_period: 1s
  build:
    context: ./config/verifier-sally
    dockerfile: Dockerfile.sally-custom
  image: vlei-sally-custom:latest  # Custom-built with agent verification
```

### 2. Files Created/In Place
```
config/verifier-sally/
├── Dockerfile.sally-custom        ✅ Custom Sally build
├── routes_patch.py               ✅ Route registration
├── custom-sally/
│   ├── __init__.py              ✅ Module init
│   ├── agent_verifying.py       ✅ Agent verification logic
│   └── handling_ext.py          ✅ Extended handlers
├── entry-point-extended.sh       ✅ Enhanced entrypoint
├── verifier.json                 ✅ Config
└── incept-no-wits.json          ✅ Inception config
```

---

## 🎯 NEXT STEPS - BUILD & DEPLOY

### Step 1: Build Images (Including Custom Sally)
```bash
cd C:\SATHYA\CHAINAIM3003\mcp-servers\stellarboston\vLEI1\vLEIWorkLinux1

# Build all images (tsx-shell AND custom verifier)
docker compose build
```

**Note:** No need to specify `verifier` - it builds automatically!

**Expected output (for verifier service):**
```
[+] Building verifier
 => [internal] load build definition
 => => transferring dockerfile: Dockerfile.sally-custom
 => CACHED [1/4] FROM gleif/sally:1.0.2
 => [2/4] COPY custom-sally /sally/custom-sally
 => [3/4] COPY routes_patch.py /sally/
 => [4/4] RUN python /sally/routes_patch.py
 => exporting to image
 => => naming to vlei-sally-custom:latest

[+] Building tsx-shell (also gets built)
 ...
```

### Step 2: Stop Current Services
```bash
./stop.sh
```

### Step 3: Deploy with Custom Sally
```bash
./deploy.sh
```

**Verification:**
```bash
# Check verifier is running with custom image
docker compose ps verifier

# Should show:
NAME         IMAGE                   STATUS
verifier     vlei-sally-custom:latest   Up (healthy)

# Check logs for custom route registration
docker logs verifier 2>&1 | grep "agent-delegation"

# Should show:
"Custom agent-delegation endpoint registered at /verify/agent-delegation"
```

### Step 4: Run Workflow Test
```bash
./run-all-buyerseller-2-with-agents.sh
```

---

## 🔍 VERIFICATION POINTS

### 1. Custom Image Built
```bash
docker images | grep sally-custom
# Should show: vlei-sally-custom    latest    <image-id>    <timestamp>
```

### 2. Custom Endpoint Available
```bash
curl http://localhost:9723/verify/agent-delegation
# Should NOT return 404 (may return 400/500 without proper payload, but endpoint exists)
```

### 3. Logs Show Custom Code
```bash
docker logs verifier 2>&1 | tail -20
# Should show custom endpoint registration
```

---

## 🐛 TROUBLESHOOTING

### Build Fails
```bash
# Clean build cache
docker compose build --no-cache

# Or build just verifier:
docker compose build --no-cache verifier

# Check Dockerfile syntax
docker compose config
```

### Endpoint Still Returns 404
```bash
# Verify routes_patch.py ran
docker exec verifier ls -la /sally/routes_patch.py

# Check if custom-sally module is imported
docker exec verifier python -c "import custom_sally; print('OK')"
```

### Container Won't Start
```bash
# Check logs
docker logs verifier

# Rebuild from scratch
docker compose down -v
docker compose build --no-cache
docker compose up verifier
```

---

## 📊 EXPECTED WORKFLOW RESULTS

### Before Custom Build (Current)
```
POST /verify/agent-delegation
→ 404 Not Found (endpoint doesn't exist)
```

### After Custom Build (Expected)
```
POST /verify/agent-delegation
→ 200 OK with agent verification
→ Logs show: "Verifying agent delegation chain for AID: {aid}"
→ Workflow continues to buyerseller-2 step
```

---

## 🎯 SUCCESS CRITERIA

- [ ] `docker compose build` completes successfully
- [ ] `docker images` shows `vlei-sally-custom:latest`
- [ ] `docker compose ps` shows verifier using custom image
- [ ] Logs show "Custom agent-delegation endpoint registered"
- [ ] `/verify/agent-delegation` endpoint responds (not 404)
- [ ] Workflow executes without verification errors
- [ ] Agent-assisted vLEI issuance completes successfully

---

## 📚 DOCUMENTATION REFERENCES

- `SALLY-BUILD-READY.md` - Quick start guide
- `SALLY-CUSTOM-BUILD-GUIDE.md` - Detailed build documentation
- `INTEGRATION-GUIDE.md` - Workflow integration details

---

## 🎉 READY TO BUILD!

Everything is configured and ready. Just run your normal workflow:

```bash
./stop.sh
docker compose build    # Builds custom Sally automatically!
./deploy.sh
./run-all-buyerseller-2-with-agents.sh
```

The `/verify/agent-delegation` endpoint will work! 🚀
