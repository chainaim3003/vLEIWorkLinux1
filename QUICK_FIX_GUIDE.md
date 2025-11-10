# Quick Start - File Persistence Fix

## What Was Wrong

Files written by TypeScript scripts in the Docker container weren't persisting to the Windows host filesystem due to async file operations combined with Docker volume mount sync delays on WSL2.

## What Was Fixed

Changed all file write operations from async (`fs.promises.writeFile`) to synchronous (`fs.writeFileSync`) with verification checks in these files:

✅ **Fixed Files:**
- `geda/geda-aid-create.ts`
- `qvi/qvi-aid-delegate-create.ts`
- `qvi/qvi-aid-delegate-finish.ts`
- `le/le-aid-create.ts`
- `person/person-aid-create.ts`
- `geda/geda-registry-create.ts`
- `qvi/qvi-registry-create.ts`
- `le/le-registry-create.ts`

## Quick Test

```bash
# Make scripts executable
chmod +x rebuild-and-test.sh

# Convert line endings (important on Windows!)
dos2unix rebuild-and-test.sh

# Run the rebuild and test script
./rebuild-and-test.sh
```

This script will:
1. Stop containers
2. Clean task-data
3. **Rebuild the tsx-shell Docker image** (CRITICAL STEP!)
4. Deploy infrastructure
5. Test GEDA creation
6. Ask if you want to run the full workflow

## Manual Steps (if you prefer)

```bash
# 1. Stop and clean
./stop.sh
rm -f ./task-data/*.json ./task-data/*.txt

# 2. Rebuild the Docker image (REQUIRED!)
docker compose build tsx-shell

# 3. Deploy
./deploy.sh

# 4. Test
./task-scripts/geda/geda-aid-create.sh
ls -la ./task-data/

# 5. If files appear, run full workflow
./run-all.sh
```

## Important Notes

⚠️ **You MUST rebuild the Docker image** after changing TypeScript files:
```bash
docker compose build tsx-shell
```

⚠️ **Always run `dos2unix` on shell scripts** when working on Windows:
```bash
find . -type f -name "*.sh" -exec dos2unix {} \;
```

⚠️ **Verify files exist** after GEDA creation:
```bash
ls -la ./task-data/
# Should show: geda-aid.txt, geda-info.json
```

## If It Still Fails

If files still don't persist after rebuilding:

1. **Check Docker Desktop settings:**
   - Ensure WSL2 integration is enabled
   - Check Resources > File Sharing includes your project directory

2. **Check volume mounts:**
```bash
docker compose exec tsx-shell ls -la /task-data/
```

3. **Try writing from container manually:**
```bash
docker compose exec tsx-shell sh -c "echo test > /task-data/test.txt"
ls -la ./task-data/
```

4. **Check disk space:**
```bash
df -h
```

## Success Indicator

You'll know it's working when you see:
```bash
$ ls -la ./task-data/
total 8
-rw-r--r-- 1 root root   46 Nov 10 10:15 geda-aid.txt
-rw-r--r-- 1 root root  156 Nov 10 10:15 geda-info.json
```

## Next Steps After Success

Once the basic test works:

1. Run the full workflow: `./run-all.sh`
2. Run the buyer-seller config: `./run-all-buyerseller-2.sh`
3. Check all generated credentials in `./task-data/`

## Documentation

- Full details: `FILE_PERSISTENCE_FIX.md`
- Original README: `README.md`
- Build instructions: `BUILD_INSTRUCTIONS.md`

---

**Note:** This fix is specific to Windows/WSL2 with Docker Desktop. The same code works fine on native Linux systems without modification.
