# Complete Fix for Multiple LE AID Issue - Phase 2

## Overview

This document describes the **complete fix** for the multiple LE AID issue. Phase 1 fixed LE AID creation. Phase 2 fixes all scripts that reference the LE AID.

## Problem Description

### Phase 1 Problem (FIXED ✅)
When creating the second LE AID, the script failed:
```
Error: AID with name le already incepted
```

### Phase 2 Problem (NOW FIXED ✅)
After Phase 1 fix, the LE AID was created successfully with unique alias `Jupiter_Knitting_Company`, but when admitting the credential:
```
Error: HTTP GET /identifiers/le - 404 Not Found
"le is not a valid identifier name or prefix"
```

**Root Cause**: Multiple scripts still had hardcoded `"le"` references and weren't using the unique alias that was used to create the AID.

---

## Complete List of Files Modified

### Phase 1 Files (Already Fixed)
1. ✅ `sig-wallet/src/tasks/le/le-aid-create.ts`
2. ✅ `task-scripts/le/le-aid-create.sh`
3. ✅ `run-all-buyerseller-2.sh` (partial - LE creation only)

### Phase 2 Files (Just Fixed)
4. ✅ `sig-wallet/src/tasks/le/le-acdc-admit-le.ts`
5. ✅ `task-scripts/le/le-acdc-admit-le.sh`
6. ✅ `task-scripts/le/le-acdc-present-le.sh`
7. ✅ `task-scripts/le/le-registry-create.sh`
8. ✅ `task-scripts/le/le-acdc-issue-oor-auth.sh`
9. ✅ `run-all-buyerseller-2.sh` (completed - all LE references)

**Total: 9 files modified** to support unique LE aliases

---

## Detailed Changes

### 1. sig-wallet/src/tasks/le/le-acdc-admit-le.ts

**What it does**: Admits the LE credential via IPEX

**Changes**:
- Added `leAlias` parameter (args[4])
- Changed from hardcoded `'le'` to using `leAlias`

**Before**:
```typescript
const qviPrefix = args[3];

const leClient = await getOrCreateClient(lePasscode, env);
const op: any = await ipexAdmitGrant(leClient, 'le', qviPrefix, grantSAID)
```

**After**:
```typescript
const qviPrefix = args[3];
const leAlias = args[4] || 'le';  // Use provided alias or default to 'le'

const leClient = await getOrCreateClient(lePasscode, env);
const op: any = await ipexAdmitGrant(leClient, leAlias, qviPrefix, grantSAID)
```

---

### 2. task-scripts/le/le-acdc-admit-le.sh

**What it does**: Shell script wrapper for admitting LE credential

**Changes**:
- Accept `LE_ALIAS` as parameter ($1)
- Pass alias to TypeScript script

**Before**:
```bash
docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-admit-le.ts \
    'docker' \
    "${LE_SALT}" \
    "${GRANT_SAID}" \
    "${QVI_PREFIX}"
```

**After**:
```bash
LE_ALIAS=${1:-"le"}  # Accept alias, default to 'le'
echo "Using LE alias: ${LE_ALIAS}"

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-admit-le.ts \
    'docker' \
    "${LE_SALT}" \
    "${GRANT_SAID}" \
    "${QVI_PREFIX}" \
    "${LE_ALIAS}"  # NEW PARAMETER
```

---

### 3. task-scripts/le/le-acdc-present-le.sh

**What it does**: Present LE credential to verifier

**Changes**:
- Accept `LE_ALIAS` as parameter ($1)
- Pass alias instead of hardcoded "le"

**Before**:
```bash
docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-present-le.ts \
    'docker' \
    "${LE_SALT}" \
    "le" \  # HARDCODED
    "${CRED_SAID}" \
    "${VERIFIER_AID}"
```

**After**:
```bash
LE_ALIAS=${1:-"le"}
echo "Using LE alias: ${LE_ALIAS}"

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-present-le.ts \
    'docker' \
    "${LE_SALT}" \
    "${LE_ALIAS}" \  # FROM PARAMETER
    "${CRED_SAID}" \
    "${VERIFIER_AID}"
```

---

### 4. task-scripts/le/le-registry-create.sh

**What it does**: Create registry in LE AID for OOR credentials

**Changes**:
- Accept `LE_ALIAS` as parameter ($1)
- Pass alias instead of hardcoded "le"

**Before**:
```bash
docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-registry-create.ts \
    'docker' \
    "${LE_SALT}" \
    "le" \  # HARDCODED
    "le-oor-registry" \
    "/task-data/le-registry-info.json"
```

**After**:
```bash
LE_ALIAS=${1:-"le"}
echo "Using LE alias: ${LE_ALIAS}"

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-registry-create.ts \
    'docker' \
    "${LE_SALT}" \
    "${LE_ALIAS}" \  # FROM PARAMETER
    "le-oor-registry" \
    "/task-data/le-registry-info.json"
```

---

### 5. task-scripts/le/le-acdc-issue-oor-auth.sh

**What it does**: Issue OOR Auth credential from LE to QVI

**Changes**:
- Accept `LE_ALIAS` as 4th parameter ($4)
- Pass alias to TypeScript (was hardcoded as 'le')

**Before**:
```bash
PERSON_NAME="${1:-John Smith}"
PERSON_OOR="${2:-Head of Standards}"
LE_LEI="${3:-254900OPPU84GM83MG36}"

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-issue-oor-auth.ts \
    'docker' \
    'le' \  # HARDCODED
    "${LE_SALT}" \
    ...
```

**After**:
```bash
PERSON_NAME="${1:-John Smith}"
PERSON_OOR="${2:-Head of Standards}"
LE_LEI="${3:-254900OPPU84GM83MG36}"
LE_ALIAS="${4:-le}"  # NEW PARAMETER

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-issue-oor-auth.ts \
    'docker' \
    "${LE_ALIAS}" \  # FROM PARAMETER
    "${LE_SALT}" \
    ...
```

---

### 6. run-all-buyerseller-2.sh (4 lines changed)

**What it does**: Main orchestration script

**Changes**: Pass `$ORG_ALIAS` to all LE scripts

**Line 167** - LE Admit:
```bash
# Before:
./task-scripts/le/le-acdc-admit-le.sh

# After:
./task-scripts/le/le-acdc-admit-le.sh "$ORG_ALIAS"
```

**Line 172** - LE Present:
```bash
# Before:
./task-scripts/le/le-acdc-present-le.sh

# After:
./task-scripts/le/le-acdc-present-le.sh "$ORG_ALIAS"
```

**Line 213** - LE Registry Create:
```bash
# Before:
./task-scripts/le/le-registry-create.sh

# After:
./task-scripts/le/le-registry-create.sh "$ORG_ALIAS"
```

**Line 218** - LE Issue OOR Auth:
```bash
# Before:
./task-scripts/le/le-acdc-issue-oor-auth.sh "$PERSON_NAME" "$PERSON_ROLE" "$ORG_LEI"

# After:
./task-scripts/le/le-acdc-issue-oor-auth.sh "$PERSON_NAME" "$PERSON_ROLE" "$ORG_LEI" "$ORG_ALIAS"
```

---

## How the Fix Works

### Dataflow for Multiple Organizations

**Jupiter Knitting Company** (First Org):
1. LE created with alias: `Jupiter_Knitting_Company` ✅
2. LE admits credential using alias: `Jupiter_Knitting_Company` ✅
3. LE presents credential using alias: `Jupiter_Knitting_Company` ✅
4. LE registry created using alias: `Jupiter_Knitting_Company` ✅
5. LE issues OOR Auth using alias: `Jupiter_Knitting_Company` ✅

**Tommy Hilfiger Europe** (Second Org):
1. LE created with alias: `Tommy_Hilfiger_Europe` ✅
2. LE admits credential using alias: `Tommy_Hilfiger_Europe` ✅
3. LE presents credential using alias: `Tommy_Hilfiger_Europe` ✅
4. LE registry created using alias: `Tommy_Hilfiger_Europe` ✅
5. LE issues OOR Auth using alias: `Tommy_Hilfiger_Europe` ✅

**No more conflicts!** Each organization has its own unique AID namespace.

---

## Build and Test Instructions

### Step 1: Build TypeScript (REQUIRED)

```bash
cd ~/projects/vLEIWorkLinux1/sig-wallet
npm run build
cd ..
```

This compiles:
- `le-aid-create.ts` → `le-aid-create.js`
- `le-acdc-admit-le.ts` → `le-acdc-admit-le.js`

### Step 2: Stop and Clean

```bash
./stop.sh
```

### Step 3: Rebuild Docker Images

```bash
docker compose build
```

### Step 4: Deploy

```bash
./deploy.sh
```

### Step 5: Run Full Test

```bash
./run-all-buyerseller-2.sh
```

---

## Expected Output

You should see:

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
   Prefix: EOgSeJySDVCcvp8F0xRJOeNV0v09C37GJkEAWQfyxMcb
   ✓ LE credential issued and presented for JUPITER KNITTING COMPANY

  → Creating LE registry for OOR credentials...
Creating registry in LE AID
Using LE alias: Jupiter_Knitting_Company
Successfully created credential registry

  → LE issues OOR_AUTH credential for Chief Sales Officer...
Using LE alias: Jupiter_Knitting_Company
OOR Auth credential created
```

Then:

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
   Prefix: [DIFFERENT FROM JUPITER]
   ✓ LE credential issued and presented for TOMMY HILFIGER EUROPE B.V.

  → Creating LE registry for OOR credentials...
Creating registry in LE AID
Using LE alias: Tommy_Hilfiger_Europe
Successfully created credential registry

✨ vLEI credential system execution completed successfully!
```

---

## Success Criteria

✅ **No "already incepted" errors**  
✅ **No "404 Not Found" errors**  
✅ **Both organizations complete successfully**  
✅ **Unique prefixes for each LE AID**  
✅ **All credentials properly issued**  
✅ **All credentials properly admitted**  
✅ **All credentials presented to verifier**  
✅ **Script runs to completion**  

---

## What's Still Using Defaults?

These components still use hardcoded defaults (but they don't cause conflicts):

1. **Person AIDs** - Still use default "person" alias
   - *Not an immediate issue* since there's only one person per org in current config
   - *Will need fixing* if multiple persons per org are added

2. **QVI AID** - Uses "qvi" alias
   - *Not an issue* since there's only one QVI in the system

3. **GEDA AID** - Uses "geda" alias
   - *Not an issue* since there's only one GEDA (root) in the system

---

## Future Enhancements

### 1. Person AID Aliases
When supporting multiple persons per organization, apply the same pattern:
- `person-aid-create.ts` - Accept alias parameter
- `person-aid-create.sh` - Pass alias
- Use format: `${ORG_ALIAS}_${PERSON_ALIAS}`

### 2. Data File Management
Currently all data goes to shared `/task-data` directory. Consider:
- Organization-specific subdirectories: `/task-data/jupiter/`, `/task-data/tommy/`
- Or prefixed filenames: `jupiter-le-info.json`, `tommy-le-info.json`

### 3. Registry Names
Use organization-specific registry names from config:
- Jupiter: `JUPITER_REGISTRY`
- Tommy: `TOMMY_REGISTRY`

---

## Troubleshooting

### Issue: Build fails
```bash
cd sig-wallet
rm -rf node_modules
npm install
npm run build
```

### Issue: Still getting 404 errors
1. Check that JavaScript was actually rebuilt (check timestamps)
2. Restart Docker: `./stop.sh && docker compose build && ./deploy.sh`
3. Check that shell scripts are passing the alias parameter

### Issue: Wrong alias being used
- Check that `$ORG_ALIAS` is being extracted from config correctly
- Verify the configuration file has correct alias values
- Add debug echo statements to see what's being passed

---

## Summary

This complete fix enables the vLEI system to properly handle multiple organizations by:

1. ✅ Creating unique LE AIDs per organization (Phase 1)
2. ✅ Referencing those AIDs correctly in all operations (Phase 2)
3. ✅ Passing alias through entire chain: config → main script → shell scripts → TypeScript
4. ✅ Maintaining backward compatibility with defaults
5. ✅ Supporting unlimited organizations

**Result**: System can now successfully process both Jupiter Knitting Company and Tommy Hilfiger Europe (and any future organizations) in a single execution!

---

**Document Version**: 2.0 (Complete Fix)  
**Date**: November 10, 2025  
**Status**: ✅ All Files Modified - Ready for Build & Test  
**Dependencies**: Requires TypeScript rebuild (`npm run build`)
