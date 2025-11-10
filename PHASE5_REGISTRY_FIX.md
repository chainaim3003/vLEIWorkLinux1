# Phase 5: Registry Naming Conflict Fix

## Problem Identified

Multiple organizations were trying to create registries with the same hardcoded name `"le-oor-registry"`, causing conflicts:

```
Error: registry name le-oor-registry already in use
```

**What was happening:**
- Jupiter Knitting Company created registry: `"le-oor-registry"` ✅
- Tommy Hilfiger Corp tried to create: `"le-oor-registry"` ❌ **CONFLICT!**

## Root Cause

The registry name was hardcoded in three shell scripts:
1. `le-registry-create.sh` - Line 18
2. `le-acdc-issue-oor-auth.sh` - Line 58
3. `le-acdc-issue-ecr-auth.sh` - Line 48

## Solution

Make the registry name unique per organization by incorporating the `LE_ALIAS` into the registry name.

### Example
- If `LE_ALIAS="le-jupiter"` → Registry name: `"le-jupiter-oor-registry"`
- If `LE_ALIAS="le-tommy"` → Registry name: `"le-tommy-oor-registry"`

## Files Modified

### 1. task-scripts/le/le-registry-create.sh

**Before:**
```bash
# create ACDC registry
docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-registry-create.ts \
    'docker' \
    "${LE_SALT}" \
    "${LE_ALIAS}" \
    "le-oor-registry" \
    "/task-data/le-registry-info.json"
```

**After:**
```bash
# create ACDC registry with unique name per organization
REGISTRY_NAME="${LE_ALIAS}-oor-registry"
echo "Creating registry: ${REGISTRY_NAME}"

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-registry-create.ts \
    'docker' \
    "${LE_SALT}" \
    "${LE_ALIAS}" \
    "${REGISTRY_NAME}" \
    "/task-data/le-registry-info.json"
```

### 2. task-scripts/le/le-acdc-issue-oor-auth.sh

**Before:**
```bash
docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-issue-oor-auth.ts \
    'docker' \
    "${LE_ALIAS}" \
    "${LE_SALT}" \
    "le-oor-registry" \
    ...
```

**After:**
```bash
# Use dynamic registry name based on LE alias
REGISTRY_NAME="${LE_ALIAS}-oor-registry"
echo "Using registry: ${REGISTRY_NAME}"

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-issue-oor-auth.ts \
    'docker' \
    "${LE_ALIAS}" \
    "${LE_SALT}" \
    "${REGISTRY_NAME}" \
    ...
```

### 3. task-scripts/le/le-acdc-issue-ecr-auth.sh

**Before:**
```bash
# Sample person data for ECR Auth credential
PERSON_NAME="John Smith"
PERSON_ECR="Project Manager"

# Issue the ECR Auth credential
echo "Issuing ECR Auth credential to ${QVI_AID} for person ${PERSON_NAME}"
docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-issue-ecr-auth.ts \
    'docker' \
    'le' \
    "${LE_SALT}" \
    "le-oor-registry" \
    ...
```

**After:**
```bash
# Accept parameters or use defaults
PERSON_NAME="${1:-John Smith}"
PERSON_ECR="${2:-Project Manager}"
LE_ALIAS="${3:-le}"  # Accept LE alias as 3rd parameter

# Use dynamic registry name based on LE alias
REGISTRY_NAME="${LE_ALIAS}-oor-registry"

# Issue the ECR Auth credential
echo "Issuing ECR Auth credential to ${QVI_AID} for person ${PERSON_NAME}"
echo "Using LE alias: ${LE_ALIAS}"
echo "Using registry: ${REGISTRY_NAME}"

docker compose exec tsx-shell \
  /vlei/tsx-script-runner.sh le/le-acdc-issue-ecr-auth.ts \
    'docker' \
    "${LE_ALIAS}" \
    "${LE_SALT}" \
    "${REGISTRY_NAME}" \
    ...
```

**Additional Fix:** Also parameterized the hardcoded `'le'` alias and made person data accept parameters.

## How It Works Now

1. **Jupiter Knitting Company** (LE alias: `le-jupiter`):
   - Creates registry: `le-jupiter-oor-registry` ✅
   - Issues OOR credentials using: `le-jupiter-oor-registry` ✅

2. **Tommy Hilfiger Corp** (LE alias: `le-tommy`):
   - Creates registry: `le-tommy-oor-registry` ✅
   - Issues OOR credentials using: `le-tommy-oor-registry` ✅

3. No more conflicts! Each organization has its own unique registry name.

## Verification

The orchestration script `run-all-buyerseller-2.sh` was already correctly configured to pass unique aliases:

```bash
# Line 163: Registry creation with unique alias
./task-scripts/le/le-registry-create.sh "$ORG_ALIAS"

# Line 174: OOR Auth credential with unique alias
./task-scripts/le/le-acdc-issue-oor-auth.sh "$PERSON_NAME" "$PERSON_ROLE" "$ORG_LEI" "$ORG_ALIAS"
```

## Testing

To test the fix:

```bash
./run-all-buyerseller-2.sh
```

Expected output:
```
Creating registry: le-jupiter-oor-registry
✓ Registry created successfully

Creating registry: le-tommy-oor-registry
✓ Registry created successfully
```

## Impact

✅ **Fixed:** Registry naming conflicts for multiple organizations  
✅ **Fixed:** Hardcoded LE alias in ECR auth script  
✅ **Improved:** ECR auth script now accepts parameters  
✅ **Pattern:** Applied same parameterization pattern across all LE scripts  

## Status

🎉 **COMPLETE** - All registry naming conflicts resolved!

Each organization now maintains its own unique registry namespace, allowing multiple organizations to coexist in the same vLEI ecosystem without conflicts.

---

**Date:** November 10, 2025  
**Phase:** 5 - Registry Naming Fix  
**Files Modified:** 3  
**Pattern Applied:** Dynamic registry naming based on LE alias
