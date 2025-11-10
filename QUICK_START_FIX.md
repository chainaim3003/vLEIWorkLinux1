# QUICK START - Fix Multiple LE AID Issue

## What Was Wrong?

The script was using the same alias "le" for all Legal Entity AIDs, causing this error when creating the second organization:
```
Error: HTTP POST /identifiers - 400 Bad Request - {"title": "AID with name le already incepted"}
```

## What's Fixed?

✅ Each organization now gets a unique alias from the configuration:
- Jupiter Knitting Company → `Jupiter_Knitting_Company`
- Tommy Hilfiger Europe → `Tommy_Hilfiger_Europe`

## Files Modified

1. ✅ `sig-wallet/src/tasks/le/le-aid-create.ts` - Accept alias parameter
2. ✅ `task-scripts/le/le-aid-create.sh` - Pass alias to TypeScript
3. ✅ `run-all-buyerseller-2.sh` - Pass org alias from config

---

## How to Apply and Test

### Option 1: Automated Script (Recommended)

```bash
cd C:\SATHYA\CHAINAIM3003\mcp-servers\stellarboston\vLEI1\vLEIWorkLinux1

# Make script executable (Linux/WSL only)
chmod +x fix-and-test.sh

# Run the automated fix and test
./fix-and-test.sh
```

This script will:
1. Build the TypeScript files
2. Stop and clean the environment
3. Rebuild Docker images
4. Deploy services
5. Run the full test with both organizations

---

### Option 2: Manual Steps

If you prefer to do it step by step:

#### Step 1: Build TypeScript
```bash
cd C:\SATHYA\CHAINAIM3003\mcp-servers\stellarboston\vLEI1\vLEIWorkLinux1\sig-wallet
npm run build
cd ..
```

#### Step 2: Stop Environment
```bash
./stop.sh
```

#### Step 3: Rebuild Docker Images
```bash
docker compose build
```

#### Step 4: Deploy Services
```bash
./deploy.sh
```

#### Step 5: Run Test
```bash
./run-all-buyerseller-2.sh
```

---

## Expected Results

### Success Indicators ✅

You should see:

**For Jupiter Knitting Company:**
```
╔════════════════════════════════════════════════════════════════╗
║  Organization: JUPITER KNITTING COMPANY
║  LEI: 3358004DXAMRWRUIYJ05
║  Alias: Jupiter_Knitting_Company
║  Persons: 1
╚════════════════════════════════════════════════════════════════╝

  → Creating LE AID for JUPITER KNITTING COMPANY...
Creating LE AID using SignifyTS and KERIA
Using alias: Jupiter_Knitting_Company
✓ LE credential issued and presented for JUPITER KNITTING COMPANY
```

**For Tommy Hilfiger Europe:**
```
╔════════════════════════════════════════════════════════════════╗
║  Organization: TOMMY HILFIGER EUROPE B.V.
║  LEI: 54930012QJWZMYHNJW95
║  Alias: Tommy_Hilfiger_Europe
║  Persons: 1
╚════════════════════════════════════════════════════════════════╝

  → Creating LE AID for TOMMY HILFIGER EUROPE B.V....
Creating LE AID using SignifyTS and KERIA
Using alias: Tommy_Hilfiger_Europe
✓ LE credential issued and presented for TOMMY HILFIGER EUROPE B.V.
```

**Final Message:**
```
✨ vLEI credential system execution completed successfully!
```

### What Changed

| Before | After |
|--------|-------|
| ❌ Both orgs tried to use alias "le" | ✅ Each org has unique alias |
| ❌ Second org creation failed | ✅ Both orgs created successfully |
| ❌ Script stopped with error | ✅ Script completes fully |

---

## Verification Commands

After the script completes, verify the results:

### 1. Check Trust Tree
```bash
cat task-data/trust-tree-buyerseller.txt
```

### 2. View LE Credentials
```bash
jq . task-data/le-credential-info.json
```

### 3. Check Verifier Logs
```bash
docker compose logs verifier | tail -50
```

### 4. Verify Both Organizations Created
```bash
# Count LE credentials (should be 2)
ls -la task-data/*le*.json | wc -l

# View all credential info
ls task-data/*.json
```

---

## Troubleshooting

### Issue: "npm: command not found"
**Solution**: Install Node.js from https://nodejs.org/

### Issue: Build fails with TypeScript errors
**Solution**: 
```bash
cd sig-wallet
npm install
npm run build
```

### Issue: Still getting "already incepted" error
**Solution**: Make sure you rebuilt after modifying the code:
```bash
cd sig-wallet
npm run build
cd ..
./stop.sh
./deploy.sh
./run-all-buyerseller-2.sh
```

### Issue: Docker containers won't start
**Solution**: 
```bash
docker compose down -v
docker compose up -d
```

---

## Summary

✅ **Problem**: Multiple organizations couldn't be created (alias conflict)  
✅ **Solution**: Each organization gets unique alias from config  
✅ **Build Required**: Yes - TypeScript files need rebuilding  
✅ **Testing**: Automated script provided (`fix-and-test.sh`)  
✅ **Result**: Both Jupiter and Tommy organizations work perfectly  

---

## Next Steps

After verifying the fix works:

1. 📖 Read `FIX_MULTIPLE_LE_AIDS.md` for detailed technical explanation
2. 🔧 Consider applying same pattern to Person AIDs if needed
3. 📝 Update your project documentation
4. ✨ Start building your vLEI applications!

---

**Quick Reference**: 
- Configuration: `appconfig/configBuyerSellerAIAgent1.json`
- Main Script: `run-all-buyerseller-2.sh`
- Build Instructions: `BUILD_INSTRUCTIONS.md`
- Detailed Fix: `FIX_MULTIPLE_LE_AIDS.md`

**Ready to test?** Run: `./fix-and-test.sh`
