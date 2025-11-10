# Summary of TypeScript Changes for File Persistence Fix

## Changes Made to Fix File Persistence on Windows/WSL2

### Problem
Files written inside Docker container using `fs.promises.writeFile()` were not persisting to the Windows host filesystem due to async operations not flushing before script exit.

### Solution Pattern
Convert all async file operations to synchronous with verification:

```typescript
// BEFORE (Broken):
await fs.promises.readFile(path, 'utf-8')
await fs.promises.writeFile(path, data)

// AFTER (Fixed):
fs.readFileSync(path, 'utf-8')
fs.writeFileSync(path, data, 'utf-8')
if (!fs.existsSync(path)) {
    throw new Error(`Failed to write ${path}`)
}
```

---

## Modified Files (8 total)

### 1. geda/geda-aid-create.ts
**Location:** `sig-wallet/src/tasks/geda/geda-aid-create.ts`

**Changes:**
- Line 13-14: Changed from `await fs.promises.writeFile` to `fs.writeFileSync`
- Added file existence verification after writes
- Added error checking

**Before:**
```typescript
await fs.promises.writeFile(`${dataDir}/geda-aid.txt`, gedaInfo.aid);
await fs.promises.writeFile(`${dataDir}/geda-info.json`, JSON.stringify(gedaInfo));
```

**After:**
```typescript
fs.writeFileSync(`${dataDir}/geda-aid.txt`, gedaInfo.aid);
fs.writeFileSync(`${dataDir}/geda-info.json`, JSON.stringify(gedaInfo, null, 2));

if (!fs.existsSync(`${dataDir}/geda-aid.txt`)) {
    throw new Error(`Failed to write ${dataDir}/geda-aid.txt`);
}
if (!fs.existsSync(`${dataDir}/geda-info.json`)) {
    throw new Error(`Failed to write ${dataDir}/geda-info.json`);
}
```

---

### 2. qvi/qvi-aid-delegate-create.ts
**Location:** `sig-wallet/src/tasks/qvi/qvi-aid-delegate-create.ts`

**Changes:**
- Line 10: Changed from `await fs.promises.readFile` to `fs.readFileSync`
- Line 10: Added existence check before reading
- Line 16: Changed from `await fs.promises.writeFile` to `fs.writeFileSync`
- Added file existence verification

**Before:**
```typescript
const gedaInfo = JSON.parse(await fs.promises.readFile(`${dataDir}/geda-info.json`, 'utf-8'));
// ...
await fs.promises.writeFile(qviPath, JSON.stringify(clientInfo));
```

**After:**
```typescript
const gedaInfoPath = `${dataDir}/geda-info.json`;
if (!fs.existsSync(gedaInfoPath)) {
    throw new Error(`GEDA info file not found: ${gedaInfoPath}`);
}
const gedaInfo = JSON.parse(fs.readFileSync(gedaInfoPath, 'utf-8'));
// ...
fs.writeFileSync(qviPath, JSON.stringify(clientInfo, null, 2));
if (!fs.existsSync(qviPath)) {
    throw new Error(`Failed to write ${qviPath}`);
}
```

---

### 3. qvi/qvi-aid-delegate-finish.ts
**Location:** `sig-wallet/src/tasks/qvi/qvi-aid-delegate-finish.ts`

**Changes:**
- Lines 43-44: Changed from `await fs.promises.readFile` to `fs.readFileSync`
- Added existence checks before reading files
- Line 53: Changed from `await fs.promises.writeFile` to `fs.writeFileSync`
- Added file existence verification

**Before:**
```typescript
const dgrInfo = JSON.parse(await fs.promises.readFile(delegatorInfoPath, 'utf-8'));
const dgtInfo = JSON.parse(await fs.promises.readFile(delegateInfoPath, 'utf-8'));
// ...
await fs.promises.writeFile(delegateOutputPath, JSON.stringify(delegationInfo));
```

**After:**
```typescript
if (!fs.existsSync(delegatorInfoPath)) {
    throw new Error(`Delegator info file not found: ${delegatorInfoPath}`);
}
const dgrInfo = JSON.parse(fs.readFileSync(delegatorInfoPath, 'utf-8'));

if (!fs.existsSync(delegateInfoPath)) {
    throw new Error(`Delegate info file not found: ${delegateInfoPath}`);
}
const dgtInfo = JSON.parse(fs.readFileSync(delegateInfoPath, 'utf-8'));
// ...
fs.writeFileSync(delegateOutputPath, JSON.stringify(delegationInfo, null, 2));
if (!fs.existsSync(delegateOutputPath)) {
    throw new Error(`Failed to write ${delegateOutputPath}`);
}
```

---

### 4. le/le-aid-create.ts
**Location:** `sig-wallet/src/tasks/le/le-aid-create.ts`

**Changes:**
- Lines 11-12: Changed from `await fs.promises.writeFile` to `fs.writeFileSync`
- Added file existence verification

**Before:**
```typescript
await fs.promises.writeFile(`${dataDir}/le-aid.txt`, leInfo.aid);
await fs.promises.writeFile(`${dataDir}/le-info.json`, JSON.stringify(leInfo));
```

**After:**
```typescript
fs.writeFileSync(`${dataDir}/le-aid.txt`, leInfo.aid);
fs.writeFileSync(`${dataDir}/le-info.json`, JSON.stringify(leInfo, null, 2));

if (!fs.existsSync(`${dataDir}/le-aid.txt`)) {
    throw new Error(`Failed to write ${dataDir}/le-aid.txt`);
}
if (!fs.existsSync(`${dataDir}/le-info.json`)) {
    throw new Error(`Failed to write ${dataDir}/le-info.json`);
}
```

---

### 5. person/person-aid-create.ts
**Location:** `sig-wallet/src/tasks/person/person-aid-create.ts`

**Changes:**
- Lines 11-12: Changed from `await fs.promises.writeFile` to `fs.writeFileSync`
- Added file existence verification

**Before:**
```typescript
await fs.promises.writeFile(`${dataDir}/person-aid.txt`, personInfo.aid);
await fs.promises.writeFile(`${dataDir}/person-info.json`, JSON.stringify(personInfo));
```

**After:**
```typescript
fs.writeFileSync(`${dataDir}/person-aid.txt`, personInfo.aid);
fs.writeFileSync(`${dataDir}/person-info.json`, JSON.stringify(personInfo, null, 2));

if (!fs.existsSync(`${dataDir}/person-aid.txt`)) {
    throw new Error(`Failed to write ${dataDir}/person-aid.txt`);
}
if (!fs.existsSync(`${dataDir}/person-info.json`)) {
    throw new Error(`Failed to write ${dataDir}/person-info.json`);
}
```

---

### 6. geda/geda-registry-create.ts
**Location:** `sig-wallet/src/tasks/geda/geda-registry-create.ts`

**Changes:**
- Line 16: Changed from `await fs.promises.writeFile` to `fs.writeFileSync`
- Added file existence verification

**Before:**
```typescript
await fs.promises.writeFile(registryInfoPath, JSON.stringify(registryInfo));
```

**After:**
```typescript
fs.writeFileSync(registryInfoPath, JSON.stringify(registryInfo, null, 2));
if (!fs.existsSync(registryInfoPath)) {
    throw new Error(`Failed to write ${registryInfoPath}`);
}
```

---

### 7. qvi/qvi-registry-create.ts
**Location:** `sig-wallet/src/tasks/qvi/qvi-registry-create.ts`

**Changes:**
- Line 16: Changed from `await fs.promises.writeFile` to `fs.writeFileSync`
- Added file existence verification

**Before:**
```typescript
await fs.promises.writeFile(registryInfoPath, JSON.stringify(registryInfo));
```

**After:**
```typescript
fs.writeFileSync(registryInfoPath, JSON.stringify(registryInfo, null, 2));
if (!fs.existsSync(registryInfoPath)) {
    throw new Error(`Failed to write ${registryInfoPath}`);
}
```

---

### 8. le/le-registry-create.ts
**Location:** `sig-wallet/src/tasks/le/le-registry-create.ts`

**Changes:**
- Line 16: Changed from `await fs.promises.writeFile` to `fs.writeFileSync`
- Added file existence verification

**Before:**
```typescript
await fs.promises.writeFile(registryInfoPath, JSON.stringify(registryInfo));
```

**After:**
```typescript
fs.writeFileSync(registryInfoPath, JSON.stringify(registryInfo, null, 2));
if (!fs.existsSync(registryInfoPath)) {
    throw new Error(`Failed to write ${registryInfoPath}`);
}
```

---

## Benefits of These Changes

1. **Synchronous Operations:** Files are guaranteed to be written before script exits
2. **Explicit Verification:** `fs.existsSync()` checks ensure files were actually created
3. **Better Error Messages:** Clear errors if file writes fail
4. **JSON Formatting:** Added `null, 2` for readable JSON output
5. **Defensive Reads:** Check file exists before attempting to read

---

## Files That May Still Need Fixing

These files were not modified but may write to `/task-data`:

- `geda/geda-acdc-issue-qvi.ts`
- `geda/geda-challenge-qvi.ts`
- `geda/geda-respond-qvi-challenge.ts`
- `geda/geda-verify-qvi-response.ts`
- `qvi/qvi-acdc-issue-le.ts`
- `qvi/qvi-acdc-issue-oor.ts`
- `qvi/qvi-acdc-issue-ecr.ts`
- `qvi/qvi-challenge-geda.ts`
- `qvi/qvi-respond-geda-challenge.ts`
- `qvi/qvi-verify-geda-response.ts`
- `le/le-acdc-issue-oor-auth.ts`
- `le/le-acdc-issue-ecr-auth.ts`

These can be fixed using the same pattern if issues arise.

---

## Verification Process

After rebuilding, verify files persist:

```bash
# 1. Create GEDA AID
./task-scripts/geda/geda-aid-create.sh

# 2. Check files exist on host
ls -la ./task-data/

# Expected output:
# geda-aid.txt
# geda-info.json
```

---

## Why This Works

On Windows/WSL2 with Docker Desktop:
- Async operations may complete in Node.js event loop before filesystem sync
- Docker volume mounts have sync delays between container and host
- Synchronous operations block until write completes
- Verification ensures filesystem sync occurred

On native Linux:
- Both async and sync operations work fine
- No volume mount sync delays
