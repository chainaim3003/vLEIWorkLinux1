# Quick Start Guide - Configuration-Driven vLEI System

## ⚡ IMMEDIATE NEXT STEPS

### Step 1: Build TypeScript Files (REQUIRED)

```bash
cd C:\SATHYA\CHAINAIM3003\mcp-servers\stellarboston\vLEI1\vLEIWorkLinux1\sig-wallet
npm run build
```

**Expected Output**:
```
> sig-wallet@1.0.0 build
> tsc
```

**Verify**:
```bash
ls src/tasks/le/le-acdc-issue-oor-auth.js
ls src/tasks/qvi/qvi-acdc-issue-oor.js
```
Both files should exist with current timestamps.

---

### Step 2: Run Configuration-Driven Flow

```bash
cd C:\SATHYA\CHAINAIM3003\mcp-servers\stellarboston\vLEI1\vLEIWorkLinux1
./run-all-buyerseller-2.sh
```

**What to Look For**:
- ✅ Green checkmarks: "✓ Using LEI ... from configuration"
- ✅ Jupiter gets LEI: `3358004DXAMRWRUIYJ05`
- ✅ Tommy gets LEI: `54930012QJWZMYHNJW95`
- ✅ Correct person names and roles from config

---

## 📋 What Was Changed

### Modified Files Summary

| File | Type | Change |
|------|------|--------|
| `le-acdc-issue-oor-auth.ts` | TypeScript | Added `leLei` parameter |
| `qvi-acdc-issue-oor.ts` | TypeScript | Added `leLei` parameter |
| `qvi-acdc-issue-le.sh` | Shell | Accept LEI parameter |
| `le-acdc-issue-oor-auth.sh` | Shell | Accept person + LEI parameters |
| `qvi-acdc-issue-oor.sh` | Shell | Accept person + LEI parameters |
| `run-all-buyerseller-2.sh` | Shell | Pass config values to scripts |

---

## ✅ What's Now Configuration-Driven

### Before (Hardcoded):
```bash
LE_LEI="254900OPPU84GM83MG36"              # Same for all
PERSON_NAME="John Smith"                   # Same for all
PERSON_OOR="Head of Standards"             # Same for all
```

### After (From Configuration):
```json
{
  "organizations": [
    {
      "lei": "3358004DXAMRWRUIYJ05",       // Jupiter
      "persons": [{
        "legalName": "Chief Sales Officer",  // Unique per person
        "officialRole": "ChiefSalesOfficer"
      }]
    },
    {
      "lei": "54930012QJWZMYHNJW95",       // Tommy
      "persons": [{
        "legalName": "Chief Procurement Officer",
        "officialRole": "ChiefProcurementOfficer"
      }]
    }
  ]
}
```

---

## 🎯 Success Indicators

After running `./run-all-buyerseller-2.sh`:

### 1. Configuration Messages
```
✓ Using LEI 3358004DXAMRWRUIYJ05 from configuration
✓ Using person: Chief Sales Officer, role: ChiefSalesOfficer
```

### 2. Credential Files
```bash
# Check Jupiter LE credential
jq '.LEI' task-data/le-credential-info.json
# Should output: "3358004DXAMRWRUIYJ05"

# Check OOR credential
jq '.personLegalName' task-data/oor-credential-info.json
# Should output: "Chief Sales Officer"
```

### 3. Trust Tree
```bash
cat task-data/trust-tree-buyerseller.txt
# Should show both Jupiter and Tommy with correct LEIs
```

---

## 🔧 Troubleshooting

### Issue: TypeScript Build Fails
```
Error: Cannot find module 'typescript'
```
**Solution**:
```bash
cd sig-wallet
npm install
npm run build
```

---

### Issue: "No such file or directory" during build
**Verify you're in the correct directory**:
```bash
pwd
# Should show: .../vLEIWorkLinux1/sig-wallet
```

---

### Issue: Scripts still using hardcoded values
**Check you've run the build**:
```bash
ls -la sig-wallet/src/tasks/le/le-acdc-issue-oor-auth.js
# Should show recent timestamp
```

If old timestamp:
```bash
cd sig-wallet
npm run build
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `IMPLEMENTATION_SUMMARY.md` | Complete change details |
| `BUILD_INSTRUCTIONS.md` | Full build documentation |
| `QUICK_START.md` | This file - rapid deployment |
| `understanding-3.md` | Original design document |
| `complete-session.md` | Design discussion record |

---

## 🎬 Full Command Sequence

```bash
# 1. Build TypeScript
cd C:\SATHYA\CHAINAIM3003\mcp-servers\stellarboston\vLEI1\vLEIWorkLinux1\sig-wallet
npm run build

# 2. Return to project root
cd ..

# 3. Run configuration-driven flow
./run-all-buyerseller-2.sh

# 4. Verify results
cat task-data/trust-tree-buyerseller.txt
```

---

## ✨ Expected Timeline

- **Build TypeScript**: ~5-10 seconds
- **Full vLEI Flow**: ~3-5 minutes
- **Trust Tree Generation**: Instant

---

## 🎉 Success!

When complete, you'll see:
```
✅ Setup Complete!

Summary:
  • GEDA (Root) and QVI established
  • 2 organizations processed:
    - JUPITER KNITTING COMPANY (1 person(s))
    - TOMMY HILFIGER EUROPE B.V. (1 person(s))
  • All credentials issued and presented to verifier
  • Trust tree visualization generated

✓ Configuration Integration:
  1. LEI values now sourced from configuration file
  2. Person names and roles sourced from configuration file
  3. All organizational data driven by JSON configuration
  4. Scripts accept parameters for flexibility

✨ vLEI credential system execution completed successfully!
```

---

## 🚀 Adding More Organizations

Edit `appconfig/configBuyerSellerAIAgent1.json`:

```json
{
  "organizations": [
    // ... existing orgs ...
    {
      "id": "neworg",
      "alias": "New_Organization",
      "name": "NEW ORGANIZATION NAME",
      "lei": "YOUR_LEI_HERE",
      "registryName": "NEWORG_REGISTRY",
      "persons": [
        {
          "alias": "Person_Alias",
          "legalName": "Person Legal Name",
          "officialRole": "RoleName"
        }
      ]
    }
  ]
}
```

Then run: `./run-all-buyerseller-2.sh`

**No code changes needed!** 🎯

---

## 📞 Need Help?

1. **Build Issues**: See `BUILD_INSTRUCTIONS.md`
2. **Design Questions**: See `understanding-3.md`
3. **Change Details**: See `IMPLEMENTATION_SUMMARY.md`
4. **Official Docs**: https://github.com/GLEIF-IT/vlei-hackathon-2025-workshop

---

**Ready to Go!** ✨

Your configuration-driven vLEI system is complete and ready for deployment.
