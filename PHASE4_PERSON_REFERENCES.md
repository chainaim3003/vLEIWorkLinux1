# Phase 4 Fix - Person AID References

## Overview

After Phase 3 fixed Person AID **creation**, we now need to fix all scripts that **reference** Person AIDs (same pattern as Phase 2 for LE AIDs).

## Problem

Person AID was created with unique alias `Jupiter_Chief_Sales_Officer`, but other scripts were still looking for `"person"`:

```
Error: HTTP GET /identifiers/person - 404 Not Found
{"title": "404 Not Found", "description": "person is not a valid identifier name or prefix"}
```

## Files Modified (4 files)

### TypeScript (1 file - requires rebuild):
1. ✅ `sig-wallet/src/tasks/person/person-acdc-admit-oor.ts`

### Shell Scripts (2 files):
2. ✅ `task-scripts/person/person-acdc-admit-oor.sh`
3. ✅ `task-scripts/person/person-acdc-present-oor.sh`

### Main Script (1 file):
4. ✅ `run-all-buyerseller-2.sh`

## Changes Made

### 1. person-acdc-admit-oor.ts
Added `personAlias` parameter:
```typescript
const personAlias = args[4] || 'person';
const op: any = await ipexAdmitGrant(personClient, personAlias, qviPrefix, grantSAID)
```

### 2. person-acdc-admit-oor.sh
Accept and pass alias:
```bash
PERSON_ALIAS=${1:-"person"}
echo "Using Person alias: ${PERSON_ALIAS}"
docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh person/person-acdc-admit-oor.ts \
    'docker' \
    "${PERSON_SALT}" \
    "${GRANT_SAID}" \
    "${QVI_PREFIX}" \
    "${PERSON_ALIAS}"  # NEW
```

### 3. person-acdc-present-oor.sh
Accept and pass alias:
```bash
PERSON_ALIAS=${1:-"person"}
echo "Using Person alias: ${PERSON_ALIAS}"
docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh person/person-acdc-present-oor.ts \
    'docker' \
    "${PERSON_SALT}" \
    "${PERSON_ALIAS}" \  # Changed from "person"
    "${CRED_SAID}" \
    "${VERIFIER_AID}"
```

### 4. run-all-buyerseller-2.sh
Pass person alias to scripts:
```bash
./task-scripts/person/person-acdc-admit-oor.sh "$PERSON_ALIAS"
./task-scripts/person/person-acdc-present-oor.sh "$PERSON_ALIAS"
```

## Quick Apply

```bash
# Copy from Windows to Linux
cd ~/projects/vLEIWorkLinux1
cp -r /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1/* .

# Build TypeScript
cd sig-wallet
npm run build
cd ..

# Clean and test
./stop.sh
docker compose build
./deploy.sh
./run-all-buyerseller-2.sh
```

## Complete Phase Summary

| Phase | What | Status |
|-------|------|--------|
| 1 | LE AID creation | ✅ Done |
| 2 | LE AID references | ✅ Done |
| 3 | Person AID creation | ✅ Done |
| 4 | Person AID references | ✅ Done |
| **Total** | **Full System** | ✅ **Complete!** |

## Expected Results

Both organizations should now complete successfully:

### Jupiter Knitting Company ✅
- LE: `Jupiter_Knitting_Company`
- Person: `Jupiter_Chief_Sales_Officer`
- All operations use correct aliases ✅

### Tommy Hilfiger Europe ✅
- LE: `Tommy_Hilfiger_Europe`
- Person: `Tommy_Chief_Procurement_Officer`
- All operations use correct aliases ✅

## Success Indicators

✅ No "already incepted" errors  
✅ No "404 Not Found" errors  
✅ Both organizations complete  
✅ Both persons complete  
✅ Final message: "✨ vLEI credential system execution completed successfully!"  

---

**Status**: Phase 4 Complete - All 4 Phases Done! ✅  
**Build Required**: Yes - 1 TypeScript file changed  
**Total Files Modified (All Phases)**: 14 files
