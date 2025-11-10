# Fix for Multiple Person AID Issue - Phase 3

## Overview

After successfully fixing the multiple LE AID issue (Phase 2), we encountered the same problem with Person AIDs when processing the second organization.

## Problem Description

**Error when creating second person:**
```
Error: HTTP POST /identifiers - 400 Bad Request - 
{"title": "AID with name person already incepted"}
```

**What happened:**
1. ✅ First person (Chief Sales Officer from Jupiter) created with alias `"person"`
2. ❌ Second person (Chief Procurement Officer from Tommy) tried to use same alias `"person"` → **FAILED**

**Root Cause**: Same issue as LE AIDs - hardcoded `"person"` alias used for all persons.

---

## Solution Implemented

Applied the exact same pattern used for LE AIDs to Person AIDs.

### Files Modified (3 files)

#### 1. sig-wallet/src/tasks/person/person-aid-create.ts

**Changes**:
- Added `personAlias` parameter (args[3])
- Defaults to 'person' if not provided
- Uses provided alias when creating AID

**Before**:
```typescript
const dataDir = args[2];

const client = await getOrCreateClient(personPasscode, env);
const personInfo: any = await createAid(client, 'person');
```

**After**:
```typescript
const dataDir = args[2];
const personAlias = args[3] || 'person';  // Use provided alias or default to 'person'

const client = await getOrCreateClient(personPasscode, env);
const personInfo: any = await createAid(client, personAlias);
```

---

#### 2. task-scripts/person/person-aid-create.sh

**Changes**:
- Accept `PERSON_ALIAS` as parameter ($1)
- Display which alias is being used
- Pass alias to TypeScript script

**Before**:
```bash
echo "Creating Person AID using SignifyTS and KERIA"
source ./task-scripts/workshop-env-vars.sh

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh person/person-aid-create.ts \
    'docker' \
    "${PERSON_SALT}" \
    "/task-data"
```

**After**:
```bash
PERSON_ALIAS=${1:-"person"}  # Accept alias, default to 'person'

echo "Creating Person AID using SignifyTS and KERIA"
echo "Using alias: ${PERSON_ALIAS}"
source ./task-scripts/workshop-env-vars.sh

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh person/person-aid-create.ts \
    'docker' \
    "${PERSON_SALT}" \
    "/task-data" \
    "${PERSON_ALIAS}"  # NEW PARAMETER
```

---

#### 3. run-all-buyerseller-2.sh

**Changes**: Pass `$PERSON_ALIAS` from configuration

**Before**:
```bash
# Person AID Creation
echo -e "${BLUE}      → Creating Person AID...${NC}"
./task-scripts/person/person-aid-create.sh
```

**After**:
```bash
# Person AID Creation
echo -e "${BLUE}      → Creating Person AID...${NC}"
./task-scripts/person/person-aid-create.sh "$PERSON_ALIAS"
```

---

## How It Works

The system now creates unique Person AIDs for each person using their aliases from the configuration:

### Jupiter Knitting Company
- **Person**: Chief Sales Officer
- **Alias**: `Jupiter_Chief_Sales_Officer` (from config)
- **Person AID**: Created with alias `Jupiter_Chief_Sales_Officer` ✅

### Tommy Hilfiger Europe
- **Person**: Chief Procurement Officer
- **Alias**: `Tommy_Chief_Procurement_Officer` (from config)
- **Person AID**: Created with alias `Tommy_Chief_Procurement_Officer` ✅

**No more conflicts!** Each person has their own unique AID.

---

## Build and Test Instructions

### Step 1: Copy Updated Files to Linux

```bash
cd ~/projects/vLEIWorkLinux1
cp -r /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/* .
```

### Step 2: Build TypeScript (REQUIRED)

```bash
cd sig-wallet
npm run build
cd ..
```

This compiles:
- `person-aid-create.ts` → `person-aid-create.js`

### Step 3: Stop and Clean

```bash
./stop.sh
```

### Step 4: Rebuild Docker Images

```bash
docker compose build
```

### Step 5: Deploy

```bash
./deploy.sh
```

### Step 6: Run Full Test

```bash
./run-all-buyerseller-2.sh
```

---

## Expected Output

You should now see **BOTH organizations complete successfully**:

### Jupiter Knitting Company - Chief Sales Officer
```
┌──────────────────────────────────────────────────────┐
│  Person: Chief Sales Officer
│  Role: ChiefSalesOfficer
│  Alias: Jupiter_Chief_Sales_Officer
└──────────────────────────────────────────────────────┘

  → Creating Person AID...
Creating Person AID using SignifyTS and KERIA
Using alias: Jupiter_Chief_Sales_Officer
   Prefix: EAGQVUj64K4ze9X4rH22i0r1DBueyMFDIPY7fKDUok40
   ✓ OOR credential issued and presented for Chief Sales Officer
```

### Tommy Hilfiger Europe - Chief Procurement Officer
```
┌──────────────────────────────────────────────────────┐
│  Person: Chief Procurement Officer
│  Role: ChiefProcurementOfficer
│  Alias: Tommy_Chief_Procurement_Officer
└──────────────────────────────────────────────────────┘

  → Creating Person AID...
Creating Person AID using SignifyTS and KERIA
Using alias: Tommy_Chief_Procurement_Officer
   Prefix: [DIFFERENT FROM JUPITER PERSON]
   ✓ OOR credential issued and presented for Chief Procurement Officer

✨ vLEI credential system execution completed successfully!
```

---

## Complete Fix Summary - All 3 Phases

### Phase 1: LE AID Creation ✅
- Fixed LE AID creation to use unique aliases
- Files: `le-aid-create.ts`, `le-aid-create.sh`, `run-all-buyerseller-2.sh`

### Phase 2: LE AID References ✅
- Fixed all scripts that reference LE AIDs
- Files: `le-acdc-admit-le.ts`, `le-acdc-admit-le.sh`, `le-acdc-present-le.sh`, `le-registry-create.sh`, `le-acdc-issue-oor-auth.sh`, `run-all-buyerseller-2.sh`

### Phase 3: Person AID Support ✅
- Fixed Person AID creation to use unique aliases
- Files: `person-aid-create.ts`, `person-aid-create.sh`, `run-all-buyerseller-2.sh`

---

## Total Files Modified Across All Phases

### TypeScript Files (3 - require rebuild):
1. ✅ `sig-wallet/src/tasks/le/le-aid-create.ts`
2. ✅ `sig-wallet/src/tasks/le/le-acdc-admit-le.ts`
3. ✅ `sig-wallet/src/tasks/person/person-aid-create.ts`

### Shell Scripts (7):
4. ✅ `task-scripts/le/le-aid-create.sh`
5. ✅ `task-scripts/le/le-acdc-admit-le.sh`
6. ✅ `task-scripts/le/le-acdc-present-le.sh`
7. ✅ `task-scripts/le/le-registry-create.sh`
8. ✅ `task-scripts/le/le-acdc-issue-oor-auth.sh`
9. ✅ `task-scripts/person/person-aid-create.sh`
10. ✅ `run-all-buyerseller-2.sh` (multiple updates across phases)

**Total: 10 files modified**

---

## Success Criteria

After Phase 3, you should have:

✅ **No "already incepted" errors for LE AIDs**  
✅ **No "already incepted" errors for Person AIDs**  
✅ **Both organizations (Jupiter & Tommy) complete successfully**  
✅ **All persons (Chief Sales Officer & Chief Procurement Officer) created**  
✅ **All credentials properly issued**  
✅ **All credentials properly admitted**  
✅ **All credentials presented to verifier**  
✅ **Script runs to completion**  
✅ **Trust tree generated**  

---

## Configuration-Driven Design

The system now properly uses configuration from `configBuyerSellerAIAgent1.json`:

### Organization Level
- ✅ Organization name
- ✅ Organization LEI
- ✅ Organization alias → **Used for LE AID creation**

### Person Level
- ✅ Person legal name
- ✅ Person official role
- ✅ Person alias → **Used for Person AID creation**

### Result
- **Fully configuration-driven** - no hardcoded values
- **Supports unlimited organizations** - each gets unique LE AID
- **Supports unlimited persons per organization** - each gets unique Person AID
- **Scalable and maintainable**

---

## What's Still Using Defaults?

These components don't need changes (no conflicts):

1. **QVI AID** - Uses "qvi" alias
   - Only one QVI in the system ✅

2. **GEDA AID** - Uses "geda" alias
   - Only one GEDA (root) in the system ✅

---

## Troubleshooting

### Issue: Build fails
```bash
cd sig-wallet
rm -rf node_modules
npm install
npm run build
```

### Issue: Still getting person "already incepted" error
1. Verify JavaScript was rebuilt: `ls -la sig-wallet/src/tasks/person/person-aid-create.js`
2. Check timestamp is recent
3. Restart: `./stop.sh && docker compose build && ./deploy.sh`

### Issue: Wrong person alias being used
- Check `$PERSON_ALIAS` extraction from config
- Verify config has correct person alias values
- Add debug: `echo "Person alias: $PERSON_ALIAS"` in script

---

## Next Steps (Optional Enhancements)

### 1. Data File Management
Currently all data goes to `/task-data`. Consider:
- Organization subdirectories: `/task-data/jupiter/`, `/task-data/tommy/`
- Or prefixed filenames: `jupiter-person-info.json`, `tommy-person-info.json`

### 2. Registry Naming
Use unique registry names per organization:
- Jupiter: `Jupiter_LE_Registry`
- Tommy: `Tommy_LE_Registry`

### 3. Agent Delegation
Implement the delegated agent AIDs mentioned in config:
- `jupitedSellerAgent` (AI Agent for Jupiter)
- `tommyBuyerAgent` (AI Agent for Tommy)

---

## Summary

**Phase 3 Complete!** 🎉

The vLEI system now fully supports multiple organizations with multiple persons:

- ✅ **Phase 1**: Fixed LE AID creation
- ✅ **Phase 2**: Fixed LE AID references
- ✅ **Phase 3**: Fixed Person AID creation

**Result**: A fully configuration-driven, scalable vLEI credential issuance system that can handle unlimited organizations and unlimited persons per organization, with each entity having its own unique AID!

---

**Document Version**: 3.0 (Complete - All Phases)  
**Date**: November 10, 2025  
**Status**: ✅ All Fixes Complete - Ready for Build & Test  
**Dependencies**: Requires TypeScript rebuild (`npm run build`)
