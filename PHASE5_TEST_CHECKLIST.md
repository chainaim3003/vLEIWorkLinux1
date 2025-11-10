# Phase 5 Verification Checklist

## Quick Test Plan

Use this checklist to verify that all registry naming conflicts have been resolved.

---

## Pre-Test Setup

- [ ] Ensure Docker containers are running
- [ ] Configuration file exists: `appconfig/configBuyerSellerAIAgent1.json`
- [ ] Clean slate: Stop and remove any existing data
  ```bash
  ./stop.sh
  docker compose down -v
  docker compose up -d
  ```

---

## Test Execution

### Test 1: Run Full System
```bash
./run-all-buyerseller-2.sh
```

### What to Watch For

#### ✅ Organization 1: Jupiter Knitting Company

**LE AID Creation:**
```
Creating LE AID
Using LE alias: le-jupiter
✓ Expected: SUCCESS
```

**Registry Creation:**
```
Creating registry in LE AID
Using LE alias: le-jupiter
Creating registry: le-jupiter-oor-registry
✓ Expected: SUCCESS (not "registry name already in use")
```

**Person AID Creation:**
```
Creating Person AID
Using Person alias: person-jupiter-sales
✓ Expected: SUCCESS
```

**OOR Credential:**
```
Issuing OOR Auth credential to QVI for person Chief Sales Officer
Using LE alias: le-jupiter
Using registry: le-jupiter-oor-registry
✓ Expected: SUCCESS
```

---

#### ✅ Organization 2: Tommy Hilfiger Europe B.V.

**LE AID Creation:**
```
Creating LE AID
Using LE alias: le-tommy
✓ Expected: SUCCESS
```

**Registry Creation:**
```
Creating registry in LE AID
Using LE alias: le-tommy
Creating registry: le-tommy-oor-registry
✓ Expected: SUCCESS (THIS WAS FAILING BEFORE - NOW FIXED!)
```

**Person AID Creation:**
```
Creating Person AID
Using Person alias: person-tommy-procurement
✓ Expected: SUCCESS
```

**OOR Credential:**
```
Issuing OOR Auth credential to QVI for person Chief Procurement Officer
Using LE alias: le-tommy
Using registry: le-tommy-oor-registry
✓ Expected: SUCCESS
```

---

## Verification Checklist

### Phase 5: Registry Naming

- [ ] **Jupiter registry created:** `le-jupiter-oor-registry`
- [ ] **Tommy registry created:** `le-tommy-oor-registry`  
- [ ] **No "registry name already in use" error**
- [ ] **Each organization uses its own registry for credentials**

### Phase 3-4: Person AID Naming (Revalidate)

- [ ] **Jupiter person AID:** `person-jupiter-sales`
- [ ] **Tommy person AID:** `person-tommy-procurement`
- [ ] **No person AID conflicts**

### Phase 1-2: LE AID Naming (Revalidate)

- [ ] **Jupiter LE AID:** `le-jupiter`
- [ ] **Tommy LE AID:** `le-tommy`
- [ ] **No LE AID conflicts**

### End-to-End Flow

- [ ] Both organizations complete without errors
- [ ] All credentials issued successfully
- [ ] All credentials presented to Sally Verifier
- [ ] Trust tree visualization created
- [ ] Final success message displayed

---

## Error Patterns to Watch For

### ❌ FAILURE PATTERNS (Should NOT see these)

1. **Registry Conflict (Phase 5 - FIXED):**
   ```
   Error: registry name le-oor-registry already in use
   ```
   ✅ **Should now see:** Unique registry names per organization

2. **Person AID Conflict (Phase 3-4 - FIXED):**
   ```
   Error: alias person already in use
   ```
   ✅ **Should now see:** Unique person aliases per person

3. **LE AID Conflict (Phase 1-2 - FIXED):**
   ```
   Error: alias le already in use
   ```
   ✅ **Should now see:** Unique LE aliases per organization

---

## Success Criteria

### ✅ ALL MUST PASS:

1. **No naming conflicts** - All AIDs and registries created successfully
2. **Unique namespaces** - Each organization maintains separate namespace
3. **Credential chains intact** - All credentials properly linked
4. **Verification successful** - Sally can verify all credentials
5. **Clean execution** - Script completes without errors

---

## File Verification

After successful run, check these files exist:

### Configuration Input
- [ ] `appconfig/configBuyerSellerAIAgent1.json`

### Generated Outputs
- [ ] `task-data/geda-info.json`
- [ ] `task-data/qvi-info.json`
- [ ] `task-data/le-info.json` (Jupiter)
- [ ] `task-data/le-registry-info.json` (Last org processed)
- [ ] `task-data/person-info.json` (Last person processed)
- [ ] `task-data/oor-auth-credential-info.json`
- [ ] `task-data/trust-tree-buyerseller.txt`

---

## Quick Diagnostic Commands

### Check Current AIDs
```bash
# View person info (last person processed)
cat task-data/person-info.json | jq '{alias, aid}'

# View LE info (last org processed)  
cat task-data/le-info.json | jq '{alias, aid}'
```

### Check Registry Info
```bash
# View registry details
cat task-data/le-registry-info.json | jq '{name, regk}'
```

### View Trust Tree
```bash
cat task-data/trust-tree-buyerseller.txt
```

---

## Troubleshooting

### If You See Registry Conflict Error

**Problem:** Error about registry name already in use

**Check:**
```bash
# Verify the fix is in place
grep "REGISTRY_NAME=" task-scripts/le/le-registry-create.sh
# Should see: REGISTRY_NAME="${LE_ALIAS}-oor-registry"

grep "REGISTRY_NAME=" task-scripts/le/le-acdc-issue-oor-auth.sh
# Should see: REGISTRY_NAME="${LE_ALIAS}-oor-registry"
```

**Solution:** Re-apply Phase 5 fixes

### If You See Person AID Conflict

**Problem:** Error about person alias already in use

**Check:**
```bash
# Verify person alias parameterization
grep "PERSON_ALIAS" task-scripts/person/person-aid-create.sh
```

**Solution:** Review Phase 3-4 documentation

### If You See LE AID Conflict

**Problem:** Error about LE alias already in use

**Check:**
```bash
# Verify LE alias parameterization
grep "LE_ALIAS" task-scripts/le/le-aid-create.sh
```

**Solution:** Review Phase 1-2 documentation

---

## Expected Console Output Summary

```
[1/5] Validating Configuration...
✓ Configuration validated
  Root: geda
  QVI: qvi-gleif
  Organizations: 2

[2/5] GEDA & QVI Setup...
✓ GEDA & QVI setup complete

[3/5] Processing Organizations...

╔════════════════════════════════════════╗
║  Organization: JUPITER KNITTING COMPANY
║  LEI: 3358004DXAMRWRUIYJ05
║  Alias: le-jupiter
║  Persons: 1
╚════════════════════════════════════════╝

  → Creating LE AID for JUPITER KNITTING COMPANY...
  → Creating registry: le-jupiter-oor-registry
  ✓ All persons processed for JUPITER KNITTING COMPANY

╔════════════════════════════════════════╗
║  Organization: TOMMY HILFIGER EUROPE B.V.
║  LEI: 54930012QJWZMYHNJW95
║  Alias: le-tommy
║  Persons: 1
╚════════════════════════════════════════╝

  → Creating LE AID for TOMMY HILFIGER EUROPE B.V...
  → Creating registry: le-tommy-oor-registry
  ✓ All persons processed for TOMMY HILFIGER EUROPE B.V.

✓ All organizations processed

[5/5] Generating Trust Tree Visualization...
✓ Trust tree visualization created

✅ Setup Complete!
✨ vLEI credential system execution completed successfully!
```

---

## Test Result Recording

### Test Run Date: __________

**Phase 5 Results:**
- [ ] ✅ PASS - Jupiter registry created uniquely
- [ ] ✅ PASS - Tommy registry created uniquely  
- [ ] ✅ PASS - No registry naming conflicts
- [ ] ✅ PASS - Credentials issued using correct registries

**Overall System:**
- [ ] ✅ PASS - Complete execution without errors
- [ ] ✅ PASS - All credentials verified by Sally
- [ ] ✅ PASS - Trust tree generated correctly

**Tester Signature:** ___________________

---

## Documentation References

- **Phase 5 Details:** `PHASE5_REGISTRY_FIX.md`
- **Complete Summary:** `COMPLETE_DEBUGGING_SUMMARY.md`
- **Phase 4 Details:** `PHASE4_PERSON_REFERENCES.md`

---

**Status:** Ready for Testing ✅
