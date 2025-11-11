# 🚀 Agent Delegation - Quick Start Guide

## ⚡ TL;DR - Run This Now

### **For Organization 1 (Jupiter Knitting)**
```bash
./run-agent-delegation-org1.sh
```

### **For Organization 2 (Buyer Company)**
```bash
./run-agent-delegation-org2.sh
```

---

## 📋 What Was Implemented Today

### ✨ **NEW FILES CREATED**
```
config/verifier-sally/custom-sally/
├── __init__.py                    ✨ NEW
├── agent_verifying.py             ✨ NEW (152 lines)
└── handling_ext.py                ✨ NEW (102 lines)

config/verifier-sally/
└── entry-point-extended.sh        ✨ NEW (137 lines)
```

### ✅ **EXISTING FILES USED**
```
sig-wallet/src/tasks/person/
├── person-delegate-agent-create.ts       ✅ EXISTS
└── person-approve-agent-delegation.ts    ✅ EXISTS

sig-wallet/src/tasks/agent/
├── agent-aid-delegate-finish.ts          ✅ EXISTS
├── agent-oobi-resolve-qvi.ts             ✅ EXISTS
├── agent-oobi-resolve-le.ts              ✅ EXISTS
├── agent-oobi-resolve-verifier.ts        ✅ EXISTS
└── agent-verify-delegation.ts            ✅ EXISTS

task-scripts/person/
├── person-delegate-agent-create.sh       ✅ EXISTS
└── person-approve-agent-delegation.sh    ✅ EXISTS

task-scripts/agent/
├── agent-aid-delegate-finish.sh          ✅ EXISTS
├── agent-oobi-resolve-qvi.sh             ✅ EXISTS
├── agent-oobi-resolve-le.sh              ✅ EXISTS
├── agent-oobi-resolve-verifier.sh        ✅ EXISTS
└── agent-verify-delegation.sh            ✅ EXISTS

Root directory/
├── run-agent-delegation-org1.sh          ✅ EXISTS
├── run-agent-delegation-org2.sh          ✅ EXISTS
└── docker-compose.yml                    ✅ UPDATED
```

---

## 🔄 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     AGENT DELEGATION FLOW                        │
└─────────────────────────────────────────────────────────────────┘

Step 1: DELEGATION REQUEST
┌──────────────┐                          ┌──────────────────┐
│    Agent     │  Initiate Delegation     │  OOR Holder      │
│ (Delegatee)  │ ───────────────────────> │  (Delegator)     │
└──────────────┘                          └──────────────────┘
      │                                            │
      │ Creates delegation request                │
      │ with OOR Holder as delegator              │
      └───────────────────────────────────────────┘

Step 2: APPROVAL
┌──────────────────┐                      ┌──────────────┐
│  OOR Holder      │  Approve & Anchor    │  OOR KEL     │
│                  │ ──────────────────>  │  (Seal)      │
└──────────────────┘                      └──────────────┘
      │
      │ Anchors delegation seal in KEL
      │ Seal contains agent's AID
      └─────────────────────────────────────

Step 3: COMPLETION
┌──────────────┐                          ┌──────────────┐
│    Agent     │  Finish Delegation       │  Agent KEL   │
│              │ ──────────────────────>  │  (Complete)  │
└──────────────┘                          └──────────────┘
      │
      │ Queries OOR Holder KEL for seal
      │ Completes own inception
      │ Adds endpoint role
      └─────────────────────────────────────

Step 4: OOBI RESOLUTION
┌──────────────┐     Resolve OOBIs        ┌──────────────┐
│    Agent     │ ──────────────────────>  │  QVI OOBI    │
│              │ ──────────────────────>  │  LE OOBI     │
│              │ ──────────────────────>  │  Sally OOBI  │
└──────────────┘                          └──────────────┘

Step 5: VERIFICATION
┌──────────────┐     POST /verify/        ┌──────────────────┐
│    Agent     │     agent-delegation     │  Sally Verifier  │
│              │ ──────────────────────>  │                  │
└──────────────┘                          └──────────────────┘
                                                   │
                    Sally Verifies:                │
                    1. Agent KEL delegation        │
                    2. OOR Holder seal             │
                    3. OOR credential              │
                    4. Credential chain            │
                    5. No revocations              │
                                                   ▼
                                          ┌──────────────────┐
                                          │  ✅ VERIFIED     │
                                          │  Agent Valid     │
                                          └──────────────────┘
```

---

## 🧪 Quick Test Commands

### **1. Verify Sally Extension Loaded**
```bash
docker compose logs verifier | grep "Custom extensions"
```
**Expected:** `✓ Custom extensions installed`

### **2. Check Agent Info After Creation**
```bash
cat task-data/jupiterSellerAgent-info.json | jq
```
**Expected:**
```json
{
  "aid": "EAgent...",
  "oobi": "http://..."
}
```

### **3. Manual Verification Test**
```bash
docker compose exec tsx-shell sh -c '
  AGENT_AID=$(cat /task-data/jupiterSellerAgent-info.json | jq -r .aid)
  OOR_AID=$(cat /task-data/Jupiter_Chief_Sales_Officer-info.json | jq -r .aid)
  
  curl -X POST http://verifier:9723/verify/agent-delegation \
    -H "Content-Type: application/json" \
    -d "{\"agent_aid\": \"$AGENT_AID\", \"oor_holder_aid\": \"$OOR_AID\"}" | jq
'
```

### **4. View All Agent Files**
```bash
ls -la task-data/*Agent*
```

---

## 🔧 Common Issues & Fixes

### **Issue: "Custom extensions not found"**
**Fix:**
```bash
docker compose restart verifier
docker compose logs -f verifier
```

### **Issue: "OOR Holder info file not found"**
**Fix:** Ensure OOR holder was created first:
```bash
# Check if file exists
ls -la task-data/Jupiter_Chief_Sales_Officer-info.json

# If missing, run OOR holder creation first
# (from your existing setup scripts)
```

### **Issue: "Delegation seal not found"**
**Fix:** Ensure approval step completed:
```bash
# Re-run approval
./task-scripts/person/person-approve-agent-delegation.sh \
  Jupiter_Chief_Sales_Officer jupiterSellerAgent
```

---

## 📁 Output Files

### **After Step 1 (Delegation Request)**
```bash
task-data/jupiterSellerAgent-delegate-info.json
{
  "aid": "EAgent...",
  "icpOpName": "delegation.EAgent..."
}
```

### **After Step 3 (Completion)**
```bash
task-data/jupiterSellerAgent-info.json
{
  "aid": "EAgent...",
  "oobi": "http://keria:3902/oobi/EAgent..."
}
```

---

## 🎯 Success Indicators

✅ **Delegation Created**
- File exists: `task-data/{agentName}-delegate-info.json`
- Contains: `aid` and `icpOpName`

✅ **Delegation Approved**
- Logs show: "approved delegation of agent"

✅ **Delegation Completed**
- File exists: `task-data/{agentName}-info.json`
- Contains: `aid` and `oobi`

✅ **OOBIs Resolved**
- Logs show: "OOBI Resolved" for QVI, LE, Sally

✅ **Verification Successful**
- Sally returns: `{"valid": true, ...}`
- Includes: `credential_chain` and `verification_timestamp`

---

## 📚 File Reference

### **Configuration Files**
| File | Purpose |
|------|---------|
| `config/verifier-sally/custom-sally/*.py` | Sally Python extensions |
| `config/verifier-sally/entry-point-extended.sh` | Sally startup with extensions |
| `docker-compose.yml` | Docker configuration |

### **TypeScript Tasks**
| File | Purpose |
|------|---------|
| `sig-wallet/src/tasks/person/person-delegate-agent-create.ts` | Create delegation request |
| `sig-wallet/src/tasks/person/person-approve-agent-delegation.ts` | Approve delegation |
| `sig-wallet/src/tasks/agent/agent-aid-delegate-finish.ts` | Complete delegation |
| `sig-wallet/src/tasks/agent/agent-oobi-resolve-*.ts` | Resolve OOBIs |
| `sig-wallet/src/tasks/agent/agent-verify-delegation.ts` | Verify via Sally |

### **Shell Scripts**
| File | Purpose |
|------|---------|
| `task-scripts/person/person-delegate-agent-create.sh` | Wrapper for delegation creation |
| `task-scripts/person/person-approve-agent-delegation.sh` | Wrapper for approval |
| `task-scripts/agent/agent-aid-delegate-finish.sh` | Wrapper for completion |
| `task-scripts/agent/agent-oobi-resolve-*.sh` | Wrappers for OOBI resolution |
| `task-scripts/agent/agent-verify-delegation.sh` | Wrapper for verification |

### **Orchestration**
| File | Purpose |
|------|---------|
| `run-agent-delegation-org1.sh` | Full workflow for Jupiter Knitting |
| `run-agent-delegation-org2.sh` | Full workflow for Buyer Company |

---

## 🔍 Detailed Documentation

For complete details, see:
- **Implementation Summary:** `AGENT-DELEGATION-IMPLEMENTATION-COMPLETE.md`
- **Design Document:** `agent-delegation-and-verification-execution-detailed-1.md`

---

## ✅ Checklist Before Running

- [ ] Docker Compose services are running
- [ ] GEDA, QVI, LE are set up
- [ ] OOR holders are created with credentials
- [ ] Sally verifier is running
- [ ] You have sourced environment variables: `source ./task-scripts/workshop-env-vars.sh`

---

**Ready to Test?**

```bash
# Organization 1
./run-agent-delegation-org1.sh

# Organization 2  
./run-agent-delegation-org2.sh
```

**Done!** 🎉
