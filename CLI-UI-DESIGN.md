# CLI-Based Issuance with UI Verification - Complete Design

## 🎯 Architecture Overview

This design separates concerns clearly:
- **Command Line**: All credential issuance and agent delegation (via demo-delegation-issuance.sh)
- **Docker**: Runs vLEI infrastructure locally
- **UI (React)**: Only verification and Docker status monitoring

```
┌─────────────────────────────────────────────────────────────┐
│                    COMMAND LINE (WSL)                       │
│  - demo-delegation-issuance.sh                             │
│  - Creates all AIDs, credentials, agents                   │
│  - Writes to task-data/*.json                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Creates data
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                DOCKER CONTAINERS (WSL2)                     │
│  - KERIA (port 3902)                                        │
│  - vlei-verification (port 9724)                            │
│  - Witnesses, Schema, Sally                                 │
│  - task-data/ volume mounted                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP API
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              BACKEND API (Node.js - Port 4000)              │
│  - Check Docker status                                      │
│  - Read task-data files                                     │
│  - Execute verification                                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ REST API
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              REACT UI (Port 3000)                           │
│  - Show Docker status (UP/DOWN)                            │
│  - Manual parameter entry for verification                  │
│  - Display verification results                             │
│  - Show payment message on success                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Phase 1: Command Line Issuance

### 1.1 Run Complete Issuance Workflow

```bash
# Navigate to project in WSL
cd ~/projects/vLEIWorkLinux1

# Run complete issuance (includes sync, build, deploy, workflow)
./demo-delegation-issuance.sh
```

**What This Does**:
1. Syncs code from Windows to WSL
2. Rebuilds Docker containers
3. Deploys all services
4. Executes `run-all-buyerseller-2-with-agents.sh`:
   - Creates GEDA and QVI
   - Creates 2 organizations (Jupiter, Tommy)
   - Creates 2 OOR holders (Chief Sales Officer, Chief Procurement Officer)
   - Issues all credentials (QVI, LE, OOR_AUTH, OOR)
   - Creates 2 agents (jupiterSellerAgent, tommyBuyerAgent)
   - Delegates agents from OOR holders
5. Generates trust tree visualization

**Output Files Created** (in task-data/):
```
task-data/
├── GEDA-info.json
├── vLEI_QVI-info.json
├── Jupiter_Legal_Entity-info.json
├── Jupiter_Chief_Sales_Officer-info.json
├── jupiterSellerAgent-info.json          ← Agent info
├── Tommy_Legal_Entity-info.json
├── Tommy_Chief_Procurement_Officer-info.json
├── tommyBuyerAgent-info.json             ← Agent info
└── trust-tree-buyerseller.txt
```

**Example Agent Info File** (`jupiterSellerAgent-info.json`):
```json
{
  "name": "jupiterSellerAgent",
  "aid": "EHHnC7rd40nPJf3kk6FEyYAPqwFpOLrBNfQtPJVoIcyn",
  "oobi": "http://keria:3902/oobi/EHHnC7rd40nPJf3kk6FEyYAPqwFpOLrBNfQtPJVoIcyn",
  "delegatedFrom": "Jupiter_Chief_Sales_Officer",
  "delegatorAID": "EJbZcL1qBh-x06SyZyM_hPGmvNUP2eNOLj4A6DPWX_Ak"
}
```

### 1.2 Extract Verification Parameters

After issuance completes, extract parameters needed for verification:

```bash
# View agent info
cat task-data/jupiterSellerAgent-info.json
cat task-data/tommyBuyerAgent-info.json

# View OOR holder info
cat task-data/Jupiter_Chief_Sales_Officer-info.json
cat task-data/Tommy_Chief_Procurement_Officer-info.json
```

**Parameters Required for UI Verification**:
1. **Agent Name**: `jupiterSellerAgent` or `tommyBuyerAgent`
2. **OOR Holder Name**: `Jupiter_Chief_Sales_Officer` or `Tommy_Chief_Procurement_Officer`
3. **Agent Passcode**: `AgentPass123` (from configuration)
4. **OOR Passcode**: `0ADckowyGuNwtJUPLeRqZvTp` (from configuration)
5. **Environment**: `docker` (for local) or `testnet`

---

## 🚀 Complete Workflow

### Step 1: Run CLI Issuance (WSL)

```bash
cd ~/projects/vLEIWorkLinux1
./demo-delegation-issuance.sh
# Wait 5-10 minutes for completion
```

### Step 2: Extract Parameters

```bash
# View agent details
cat task-data/jupiterSellerAgent-info.json

# Note these values:
# - agentName: jupiterSellerAgent
# - oorHolderName: Jupiter_Chief_Sales_Officer
# - agentPasscode: AgentPass123
# - oorPasscode: 0ADckowyGuNwtJUPLeRqZvTp
```

### Step 3: Start Backend (Windows Terminal)

```bash
cd backend
npm install
npm run dev
# Server starts on http://localhost:4000
```

### Step 4: Start Frontend (Windows Terminal)

```bash
cd frontend
npm install
npm start
# Opens browser at http://localhost:3000
```

### Step 5: Use UI for Verification

1. Check Docker Status (auto-updates every 10 seconds)
2. Enter verification parameters manually
3. Click "Verify Agent Delegation"
4. View results + payment message on success

---

## 🎯 Key Features

### Docker Status Monitoring
- Real-time status checks every 10 seconds
- Shows health of all services (KERIA, verification, witnesses, etc.)
- Visual indicators: 🟢 Healthy | 🟡 Starting | 🔴 Down

### Manual Parameter Entry
- Agent name (from task-data)
- OOR Holder name (from task-data)
- Agent passcode (from scripts)
- OOR passcode (from scripts)
- Environment selection (docker/testnet)

### Verification Execution
- Executes `test-agent-verification-DEEP.sh`
- Shows real-time verification steps
- Displays all AIDs and delegation chain

### Payment Message
When verification succeeds, UI shows:
```
✅ Verification Complete - Ready for Payment
🚀 Initiating stablecoin payment...
📝 Transaction will be recorded on-chain
```

---

## 📝 Summary

**This design provides**:
✅ Complete CLI-based issuance via demo-delegation-issuance.sh
✅ Docker status monitoring in UI
✅ Manual parameter entry from logs/scripts
✅ DEEP verification execution
✅ Payment message on verification success
✅ Production-grade workflow separation

**Workflow**:
```
1. Developer runs: ./demo-delegation-issuance.sh (CLI)
   ↓
2. Docker containers running with agents created
   ↓
3. Developer extracts parameters from logs
   ↓
4. User opens UI, sees Docker status
   ↓
5. User enters parameters manually
   ↓
6. User clicks Verify
   ↓
7. Backend executes DEEP verification
   ↓
8. UI shows results + payment message
```

### Advantages

1. **Simplicity**: UI only does verification
2. **Reliability**: CLI scripts are tested and robust
3. **Flexibility**: Parameters can be researched manually
4. **Debugging**: Full logs available from CLI
5. **Production-Ready**: CLI scripts are deployment-grade

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-13  
**For**: vLEIWorkLinux1 v1.0.9  
**Architecture**: CLI Issuance + UI Verification Only
