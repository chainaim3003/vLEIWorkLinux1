# 🔧 Sally Custom Build - Complete Guide

## ✅ YOU WERE RIGHT!

Yes, the design document specified we could **rebuild Sally with custom extensions from the codebase**. Here's the complete implementation.

---

## 📂 FILES CREATED

```
config/verifier-sally/
├── Dockerfile.sally-custom          ✨ NEW - Custom Sally image
├── routes_patch.py                  ✨ NEW - Route registration script
├── custom-sally/                    ✨ NEW - Custom Python modules
│   ├── __init__.py                 ✅ Already created
│   ├── agent_verifying.py          ✅ Already created
│   └── handling_ext.py             ✅ Already created
├── entry-point.sh                  ✅ Existing (use this, not extended)
├── verifier.json                   ✅ Existing
└── incept-no-wits.json             ✅ Existing
```

---

## 🏗️ HOW IT WORKS

### **The Dockerfile Approach**

```dockerfile
FROM gleif/sally:1.0.2

# Copy custom verification modules into Sally's Python packages
COPY custom-sally/agent_verifying.py /usr/local/lib/python3.12/site-packages/sally/core/
COPY custom-sally/handling_ext.py /usr/local/lib/python3.12/site-packages/sally/core/

# Copy and run the routes patch script
COPY routes_patch.py /sally/routes_patch.py
RUN python3 /sally/routes_patch.py

ENTRYPOINT ["sally"]
```

**What happens:**
1. ✅ Starts with official Sally image
2. ✅ Copies your custom Python modules into Sally's package
3. ✅ Runs patch script to register custom routes
4. ✅ Creates new image with custom verification endpoint

---

## 🚀 BUILD & DEPLOY INSTRUCTIONS

### **Step 1: Update docker-compose.yml**

Edit `docker-compose.yml` - Change the verifier service:

**FROM** (current - uses pre-built image):
```yaml
verifier:
  stop_grace_period: 1s
  image: gleif/sally:1.0.2
  # ... rest of config ...
```

**TO** (new - builds custom image):
```yaml
verifier:
  stop_grace_period: 1s
  build:
    context: ./config/verifier-sally
    dockerfile: Dockerfile.sally-custom
  image: vlei-sally-custom:latest  # Tag for the custom image
  # ... rest of config ...
```

### **Complete verifier service config:**

```yaml
verifier:
  stop_grace_period: 1s
  build:
    context: ./config/verifier-sally
    dockerfile: Dockerfile.sally-custom
  image: vlei-sally-custom:latest
  environment:
    PYTHONUNBUFFERED: 1
    PYTHONIOENCODING: UTF-8
    PYTHONWARNINGS: ignore::SyntaxWarning
    SALLY_KS_NAME: verifier
    SALLY_SALT: 0ABVqAtad0CBkhDhCEPd514T
    SALLY_PASSCODE: 4TBjjhmKu9oeDp49J7Xdy
    SALLY_PORT: 9723
    WEBHOOK_URL: http://resource:9923
    GEDA_PRE: ${GEDA_PRE}
  volumes:
    - ./config/verifier-sally/verifier.json:/sally/conf/keri/cf/verifier.json
    - ./config/verifier-sally/incept-no-wits.json:/sally/conf/incept-no-wits.json
    - ./config/verifier-sally/entry-point.sh:/sally/entry-point.sh
    - verifier-vol:/usr/local/var/keri
  healthcheck:
    test: [ "CMD", "wget", "--spider", "--tries=1", "--no-verbose", "http://127.0.0.1:9723/health" ]
    interval: 3s
    timeout: 3s
    retries: 4
    start_period: 2s
  ports:
    - "9723:9723"
  entrypoint: "/sally/entry-point.sh"
  depends_on:
    schema:
      condition: service_healthy
```

---

### **Step 2: Build the Custom Image**

```bash
# Build Sally with custom extensions
docker compose build verifier

# This will:
# 1. Pull gleif/sally:1.0.2 as base
# 2. Copy your custom Python files
# 3. Run routes_patch.py
# 4. Create vlei-sally-custom:latest
```

**Expected output:**
```
[+] Building 45.2s (10/10) FINISHED
 => [internal] load build definition
 => [internal] load .dockerignore
 => [internal] load metadata for docker.io/gleif/sally:1.0.2
 => [1/5] FROM docker.io/gleif/sally:1.0.2
 => [internal] load build context
 => [2/5] COPY custom-sally/agent_verifying.py /usr/local/lib/python3.12/site-packages/sally/core/
 => [3/5] COPY custom-sally/handling_ext.py /usr/local/lib/python3.12/site-packages/sally/core/
 => [4/5] COPY routes_patch.py /sally/routes_patch.py
 => [5/5] RUN python3 /sally/routes_patch.py
 => exporting to image
 => => naming to vlei-sally-custom:latest
```

---

### **Step 3: Deploy**

```bash
# Stop existing services
./stop.sh

# Start with custom Sally
./deploy.sh

# Verify Sally is running with custom extensions
docker compose logs verifier | grep -i custom
```

**Expected log output:**
```
✓ Routes patch written to /usr/local/lib/python3.12/site-packages/sally/core/custom_routes.py
✓ Custom routes will be registered when Sally starts
```

---

### **Step 4: Test the Custom Endpoint**

```bash
# Test the new verification endpoint
curl -X POST http://localhost:9723/verify/agent-delegation \
  -H "Content-Type: application/json" \
  -d '{
    "agent_aid": "EAgent...",
    "oor_holder_aid": "EOOR..."
  }'
```

---

## 🔄 DEVELOPMENT WORKFLOW

### **Making Changes to Custom Code**

```bash
# 1. Edit custom Python files
nano config/verifier-sally/custom-sally/agent_verifying.py

# 2. Rebuild Sally image
docker compose build verifier

# 3. Restart verifier
./stop.sh
./deploy.sh

# 4. Test
curl -X POST http://localhost:9723/verify/agent-delegation -H "Content-Type: application/json" -d '{"agent_aid":"test","oor_holder_aid":"test"}'
```

### **Quick Rebuild (No Cache)**

```bash
# Force complete rebuild
docker compose build --no-cache verifier
```

---

## 📊 VERIFICATION CHECKLIST

After building and deploying, verify:

- [ ] **Image built successfully**
  ```bash
  docker images | grep vlei-sally-custom
  ```
  Expected: `vlei-sally-custom   latest   ...`

- [ ] **Container running**
  ```bash
  docker compose ps | grep verifier
  ```
  Expected: `Up (healthy)`

- [ ] **Custom routes registered**
  ```bash
  docker compose logs verifier | grep -i custom
  ```
  Expected: `✓ Custom routes will be registered`

- [ ] **Health check passes**
  ```bash
  curl http://localhost:9723/health
  ```
  Expected: HTTP 200

- [ ] **Custom endpoint available**
  ```bash
  curl -X POST http://localhost:9723/verify/agent-delegation \
    -H "Content-Type: application/json" \
    -d '{"agent_aid":"test","oor_holder_aid":"test"}'
  ```
  Expected: JSON response (not 404)

---

## 🎯 COMPLETE WORKFLOW

```bash
# 1. Stop everything
./stop.sh

# 2. Build custom Sally
docker compose build verifier

# 3. Deploy
./deploy.sh

# 4. Run workflow with agent delegation
./run-all-buyerseller-2-with-agents.sh

# Agents will be created, delegated, AND verified by Sally!
```

---

## 📁 FILE STRUCTURE SUMMARY

```
vLEIWorkLinux1/
├── config/verifier-sally/
│   ├── Dockerfile.sally-custom      ✨ Builds custom Sally
│   ├── routes_patch.py              ✨ Registers custom routes
│   ├── custom-sally/                ✨ Custom Python modules
│   │   ├── __init__.py
│   │   ├── agent_verifying.py      ← Verification logic
│   │   └── handling_ext.py         ← HTTP endpoint
│   ├── entry-point.sh              ✅ Startup script (existing)
│   ├── verifier.json               ✅ Config (existing)
│   └── incept-no-wits.json         ✅ AID config (existing)
│
└── docker-compose.yml              ← UPDATE THIS (build instead of image)
```

---

## 🔍 TROUBLESHOOTING

### **Issue: Build fails**

```bash
# Check build context
ls -la config/verifier-sally/custom-sally/

# Ensure all files exist:
# - agent_verifying.py
# - handling_ext.py
# - __init__.py
# - Dockerfile.sally-custom
# - routes_patch.py
```

### **Issue: Custom endpoint not available**

```bash
# Check if routes_patch ran
docker compose logs verifier | grep "Routes patch"

# Expected: "✓ Routes patch written to..."
```

### **Issue: Container won't start**

```bash
# Check logs
docker compose logs verifier

# Common issues:
# - Python syntax error in custom files
# - Missing dependencies
# - Entry point permissions
```

---

## ✅ ADVANTAGES OF THIS APPROACH

1. **✅ Clean Integration** - Custom code built into image
2. **✅ No Runtime Mounting** - Everything baked in
3. **✅ Version Control** - Custom image is versioned
4. **✅ Production Ready** - Can push to registry
5. **✅ Fast Startup** - No copying files at runtime
6. **✅ Testable** - Can test image independently

---

## 📝 NEXT STEPS

1. **Update docker-compose.yml** - Add build section to verifier service
2. **Build image** - Run `docker compose build verifier`
3. **Deploy** - Run `./stop.sh && ./deploy.sh`
4. **Test** - Run the agent delegation workflow
5. **Verify** - Check that Sally verification endpoint works

---

##⚡ ONE-LINE SETUP

```bash
# Complete setup in one command:
./stop.sh && docker compose build verifier && ./deploy.sh && docker compose logs verifier | grep -i custom
```

**Expected output:**
```
✓ Routes patch written to /usr/local/lib/python3.12/site-packages/sally/core/custom_routes.py
✓ Custom routes will be registered when Sally starts
```

---

**This is the proper approach from the design document!** 🎉

The custom Sally image will have the `/verify/agent-delegation` endpoint built-in and ready to use.
