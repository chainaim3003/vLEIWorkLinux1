# File Persistence Fix for vLEI Workshop on Windows/WSL2

## Problem Summary

When running the vLEI workshop on Windows with WSL2 and Docker Desktop, files written by Node.js TypeScript scripts inside the Docker container were not persisting to the host filesystem. This caused the workflow to fail at the QVI delegation step with the error:

```
Error: ENOENT: no such file or directory, open '/task-data/geda-info.json'
```

## Root Cause

The issue was caused by **asynchronous file write operations** (`fs.promises.writeFile`) combined with **Docker volume mount sync delays** on Windows/WSL2. The async operations would complete in the Node.js event loop, but the actual file system writes weren't guaranteed to be flushed to the host before the script exited.

## Solution

Convert all async file operations to **synchronous operations** with explicit error checking:

### Before (Broken):
```typescript
await fs.promises.writeFile(`${dataDir}/geda-info.json`, JSON.stringify(gedaInfo));
```

### After (Fixed):
```typescript
fs.writeFileSync(`${dataDir}/geda-info.json`, JSON.stringify(gedaInfo, null, 2));
if (!fs.existsSync(`${dataDir}/geda-info.json`)) {
    throw new Error(`Failed to write ${dataDir}/geda-info.json`);
}
```

## Files Fixed

The following critical files have been updated:

1. **AID Creation Files:**
   - ✅ `geda/geda-aid-create.ts`
   - ✅ `qvi/qvi-aid-delegate-create.ts`
   - ✅ `qvi/qvi-aid-delegate-finish.ts`
   - ✅ `le/le-aid-create.ts`
   - ✅ `person/person-aid-create.ts`

2. **Registry Creation Files:**
   - ✅ `geda/geda-registry-create.ts`
   - ✅ `qvi/qvi-registry-create.ts`
   - ✅ `le/le-registry-create.ts`

3. **Additional Files to Fix:**
   - ⚠️ Challenge and credential issuance files (see list below)

## Remaining Files to Check

The following files may still need updating if they write to `/task-data`:

```
geda/geda-acdc-issue-qvi.ts
geda/geda-challenge-qvi.ts
geda/geda-respond-qvi-challenge.ts
geda/geda-verify-qvi-response.ts
qvi/qvi-acdc-issue-le.ts
qvi/qvi-acdc-issue-oor.ts
qvi/qvi-acdc-issue-ecr.ts
qvi/qvi-challenge-geda.ts
qvi/qvi-respond-geda-challenge.ts
qvi/qvi-verify-geda-response.ts
le/le-acdc-issue-oor-auth.ts
le/le-acdc-issue-ecr-auth.ts
```

## How to Apply the Fix

### Step 1: Rebuild the Docker Image

After making the TypeScript changes, you must rebuild the tsx-shell Docker image:

```bash
cd /mnt/c/SATHYA/CHAINAIM3003/mcp-servers/stellarboston/vLEI1/vLEIWorkLinux1

# Stop existing containers
./stop.sh

# Rebuild the tsx-shell image
docker compose build tsx-shell

# Or rebuild all services
docker compose build
```

### Step 2: Deploy and Test

```bash
# Deploy the infrastructure
./deploy.sh

# Run the complete workflow
./run-all.sh
```

### Step 3: Verify Files Are Persisting

Check that files appear in the task-data directory:

```bash
ls -la ./task-data/
```

You should see files like:
- `geda-aid.txt`
- `geda-info.json`
- `qvi-info.json`
- `le-info.json`
- etc.

## Alternative: Use Automated Fix Script

If there are many remaining files to fix, you can use the provided script:

```bash
# This script finds and converts all fs.promises operations to synchronous
./fix-async-file-writes.sh

# Then rebuild
docker compose build tsx-shell
```

## Why This Works

1. **Synchronous Operations:** `fs.writeFileSync()` blocks until the write completes
2. **Explicit Flushing:** Synchronous writes ensure data is flushed to the filesystem
3. **Verification:** The `fs.existsSync()` check ensures the file actually exists before continuing
4. **Error Handling:** Clear error messages if file writes fail

## Testing the Fix

To test if the fix worked:

```bash
# Clean start
./stop.sh
rm -f ./task-data/*.json ./task-data/*.txt

# Deploy
./deploy.sh

# Run GEDA creation only
./task-scripts/geda/geda-aid-create.sh

# Verify file exists
ls -la ./task-data/
cat ./task-data/geda-info.json
```

If you see the `geda-info.json` file with valid JSON content, the fix is working.

## Additional Improvements

For even more reliability, you could:

1. **Add delays:** Insert small delays after file writes to allow Docker volume sync
2. **Use fsync:** Explicitly call `fs.fsyncSync()` after writes
3. **Verify in host:** Add checks that verify files from the host side before continuing

## References

- Docker Desktop for Windows: https://docs.docker.com/desktop/install/windows-install/
- WSL2 filesystem performance: https://docs.microsoft.com/en-us/windows/wsl/filesystems
- Node.js fs module: https://nodejs.org/api/fs.html

## Notes

- This issue is specific to Windows/WSL2 with Docker Desktop
- The same code works fine on native Linux systems
- The working instance (`vLEIwkLin/vLEIWorkLinux1`) had these fixes already applied
- Always run `dos2unix` on shell scripts when working on Windows
