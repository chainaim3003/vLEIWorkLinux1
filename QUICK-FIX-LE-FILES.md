# 🔧 QUICK FIX: LE File Naming

## ✅ BOTH FIXES APPLIED

Fixed file naming for **both** Person and LE AIDs:

### Files Fixed:
1. ✅ `sig-wallet/src/tasks/person/person-aid-create.ts`
2. ✅ `sig-wallet/src/tasks/le/le-aid-create.ts`

### What Changed:
Both now create **alias-based filenames** needed by agent workflow:
- `Jupiter_Chief_Sales_Officer-info.json` (Person)
- `Jupiter_Knitting_Company-info.json` (LE)
- Plus legacy `person-info.json` and `le-info.json` for backwards compatibility

## 🚀 APPLY FIX ON LINUX SERVER

```bash
cd ~/projects/vLEIWorkLinux1

# Copy latest fixes from Windows
cp -r /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/sig-wallet ~/projects/vLEIWorkLinux1/

# Fix line endings
find . -type f -name "*.sh" -exec dos2unix {} \;
chmod +x *.sh

# Stop and rebuild
./stop.sh
docker compose build --no-cache tsx-shell

# Deploy and run
./deploy.sh
./run-all-buyerseller-2-with-agents.sh
```

## 📋 WHAT WILL HAPPEN

After rebuild, these files will be created:
- ✅ `/task-data/Jupiter_Chief_Sales_Officer-info.json`
- ✅ `/task-data/Jupiter_Knitting_Company-info.json`
- ✅ `/task-data/jupitedSellerAgent-info.json`

The agent workflow will find all required files! ✅

## 🎯 ROOT CAUSE

TypeScript files need to be **recompiled** inside Docker container.
The fix is already in the Windows directory - just needs to be:
1. Copied to Linux
2. Rebuilt in Docker

---

## ⚡ ONE-LINER

```bash
cd ~/projects/vLEIWorkLinux1 && cp -r /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/sig-wallet ~/projects/vLEIWorkLinux1/ && find . -type f -name "*.sh" -exec dos2unix {} \; && chmod +x *.sh && ./stop.sh && docker compose build --no-cache tsx-shell && ./deploy.sh && ./run-all-buyerseller-2-with-agents.sh
```

This will complete the full workflow! 🎉
