# 🔄 Integration Guide - Agent Delegation into Your Workflow

## 📋 TL;DR - What You Should Do

**RECOMMENDED: Use the integrated script**

```bash
# Your normal workflow (UPDATED):
./stop.sh
docker compose build
./deploy.sh
./run-all-buyerseller-2-with-agents.sh  # ← NEW! Use this instead
```

---

## ✅ OPTION 1: Integrated Workflow (RECOMMENDED)

### **What Was Created**

I created a **NEW** version of your script with agent delegation integrated:

📄 **`run-all-buyerseller-2-with-agents.sh`** ✨ NEW

This script does **everything** your original script does, PLUS:
- Creates agents for each person (from config)
- Delegates agents from OOR holders  
- Verifies agent delegation via Sally
- Includes agents in trust tree visualization

### **Complete Workflow**

```bash
# 1. Stop everything
./stop.sh

# 2. Build TypeScript container
docker compose build

# 3. Deploy services
./deploy.sh

# 4. Run COMPLETE workflow (including agents)
./run-all-buyerseller-2-with-agents.sh
```

### **What Happens During Execution**

```
[1/5] Configuration Validation ✓
[2/5] GEDA & QVI Setup ✓
[3/5] Organizations (Jupiter & Tommy Hilfiger)
   ├─ LE Creation & Credentials ✓
   [4/5] Persons (Chief Sales Officer, Chief Procurement Officer)
      ├─ Person AID Creation ✓
      ├─ OOR Credential Issuance ✓
      ├─ Credential Presentation ✓
      └─ ✨ AGENT DELEGATION ✨
         ├─ [1/5] Create delegation request ✓
         ├─ [2/5] OOR Holder approves ✓
         ├─ [3/5] Agent completes delegation ✓
         ├─ [4/5] Agent resolves OOBIs ✓
         └─ [5/5] Sally verifies delegation ✓
[5/5] Trust Tree Visualization (with agents) ✓

✅ Complete!
```

### **Make the Script Executable**

```bash
chmod +x run-all-buyerseller-2-with-agents.sh
```

---

## ⚙️ OPTION 2: Keep Scripts Separate (Alternative)

If you prefer to keep your original workflow unchanged:

```bash
# 1. Stop everything
./stop.sh

# 2. Build
docker compose build

# 3. Deploy
./deploy.sh

# 4. Run your original workflow (creates GEDA/QVI/LE/OOR)
./run-all-buyerseller-2.sh

# 5. THEN run agent delegation separately
./run-agent-delegation-org1.sh
./run-agent-delegation-org2.sh
```

---

## 🔍 What's Different Between the Scripts?

### **Original: `run-all-buyerseller-2.sh`**
```bash
# Check for delegated agents
if [ "$AGENT_COUNT" -gt 0 ]; then
    echo "NOTE: Agent delegation not yet implemented"
    echo "TODO: Implement agent AID creation and delegation"
fi
```

### **New: `run-all-buyerseller-2-with-agents.sh`**
```bash
# Check for delegated agents
if [ "$AGENT_COUNT" -gt 0 ]; then
    # ✨ ACTUAL IMPLEMENTATION
    # Step 1: Create delegation request
    ./task-scripts/person/person-delegate-agent-create.sh "$PERSON_ALIAS" "$AGENT_ALIAS"
    
    # Step 2: OOR Holder approves
    ./task-scripts/person/person-approve-agent-delegation.sh "$PERSON_ALIAS" "$AGENT_ALIAS"
    
    # Step 3: Agent completes delegation
    ./task-scripts/agent/agent-aid-delegate-finish.sh "$AGENT_ALIAS" "$PERSON_ALIAS"
    
    # Step 4: Agent resolves OOBIs
    ./task-scripts/agent/agent-oobi-resolve-qvi.sh "$AGENT_ALIAS"
    ./task-scripts/agent/agent-oobi-resolve-le.sh "$AGENT_ALIAS" "$ORG_ALIAS"
    ./task-scripts/agent/agent-oobi-resolve-verifier.sh "$AGENT_ALIAS"
    
    # Step 5: Verify via Sally
    ./task-scripts/agent/agent-verify-delegation.sh "$AGENT_ALIAS" "$PERSON_ALIAS"
fi
```

---

## 📂 File Comparison

| File | Purpose | Status |
|------|---------|--------|
| `run-all-buyerseller-2.sh` | Original workflow | ✅ Keep as-is (agents not implemented) |
| `run-all-buyerseller-2-with-agents.sh` | NEW - Complete workflow with agents | ✨ NEW - Use this |
| `run-agent-delegation-org1.sh` | Standalone agent workflow (Jupiter) | ✅ Keep for manual testing |
| `run-agent-delegation-org2.sh` | Standalone agent workflow (Tommy) | ✅ Keep for manual testing |

---

## 🎯 Configuration Requirements

Your `appconfig/configBuyerSellerAIAgent1.json` should have agents defined:

```json
{
  "organizations": [
    {
      "persons": [
        {
          "alias": "Jupiter_Chief_Sales_Officer",
          "legalName": "Jane Doe",
          "officialRole": "Chief Sales Officer",
          "agents": [
            {
              "alias": "jupiterSellerAgent",
              "agentType": "AI Agent"
            }
          ]
        }
      ]
    }
  ]
}
```

### **Verify Your Config Has Agents**

```bash
cat appconfig/configBuyerSellerAIAgent1.json | jq '.organizations[].persons[].agents'
```

**Expected output:**
```json
[
  {
    "alias": "jupiterSellerAgent",
    "agentType": "AI Agent"
  }
]
[
  {
    "alias": "tommyBuyerAgent",
    "agentType": "AI Agent"
  }
]
```

---

## ✅ RECOMMENDED WORKFLOW

### **Step-by-Step Instructions**

```bash
# Navigate to your project
cd C:\SATHYA\CHAINAIM3003\mcp-servers\stellarboston\vLEI1\vLEIWorkLinux1

# 1. Stop services
./stop.sh

# 2. Build (if TypeScript changed)
docker compose build

# 3. Deploy services
./deploy.sh

# 4. Wait for services to be healthy (2-3 minutes)
docker compose ps

# 5. Make new script executable (if not already)
chmod +x run-all-buyerseller-2-with-agents.sh

# 6. Run COMPLETE workflow with agents
./run-all-buyerseller-2-with-agents.sh
```

### **Expected Duration**
- Stop: ~10 seconds
- Build: ~2-5 minutes (first time), ~30 seconds (subsequent)
- Deploy: ~30-60 seconds
- Workflow: ~5-10 minutes (includes agent delegation)
- **Total: ~10-15 minutes**

---

## 📊 Output Files Created

### **Original Workflow Files**
```
task-data/
├── geda-info.json
├── qvi-info.json
├── Jupiter_Knitting-info.json
├── Jupiter_Chief_Sales_Officer-info.json
├── Buyer_Company_LE-info.json
└── Tommy_Buyer_OOR-info.json
```

### **NEW Agent Files** ✨
```
task-data/
├── jupiterSellerAgent-delegate-info.json  (intermediate)
├── jupiterSellerAgent-info.json           (final)
├── tommyBuyerAgent-delegate-info.json     (intermediate)
└── tommyBuyerAgent-info.json              (final)
```

---

## 🔍 Verification

### **Check Agent Creation**

```bash
# List all agent files
ls -la task-data/*Agent*

# View agent info
cat task-data/jupiterSellerAgent-info.json | jq
cat task-data/tommyBuyerAgent-info.json | jq
```

**Expected output:**
```json
{
  "aid": "EAgent...",
  "oobi": "http://keria:3902/oobi/EAgent..."
}
```

### **Check Sally Verification Logs**

```bash
# Search for verification in workflow output
grep -A 5 "Sally verifies" task-data/trust-tree-buyerseller.txt
```

---

## 🚨 Troubleshooting

### **Issue: "Agent delegation not yet implemented" still shows**

**Cause:** You're running the old script  
**Fix:** Use `run-all-buyerseller-2-with-agents.sh` instead

### **Issue: Agent files not created**

**Cause:** Config doesn't have agents defined  
**Fix:** Check `appconfig/configBuyerSellerAIAgent1.json` has agents array

### **Issue: Sally verification fails**

**Cause:** Sally extensions not loaded  
**Fix:** 
```bash
docker compose restart verifier
docker compose logs verifier | grep "Custom extensions"
```

### **Issue: Script fails at agent delegation**

**Cause:** Prerequisites (OOR holders) not created properly  
**Fix:** Check that person-info.json files exist before agent delegation runs

---

## 📚 Documentation Reference

| Document | When to Use |
|----------|-------------|
| This Guide | Integration instructions |
| `AGENT-DELEGATION-QUICK-START.md` | Quick command reference |
| `AGENT-DELEGATION-IMPLEMENTATION-COMPLETE.md` | Deep technical details |
| `PRE-FLIGHT-CHECKLIST.md` | Before running workflows |

---

## 🎯 Decision Matrix

### **Use Integrated Script If:**
- ✅ You want everything automated
- ✅ You want agents created automatically
- ✅ You're running the complete workflow from scratch
- ✅ You want one command to do everything

### **Use Separate Scripts If:**
- ✅ You want to test agent delegation independently
- ✅ You already have OOR holders set up
- ✅ You're debugging agent-specific issues
- ✅ You want granular control

---

## 📋 Quick Reference

### **Integrated Workflow** (Recommended)
```bash
./stop.sh && docker compose build && ./deploy.sh && ./run-all-buyerseller-2-with-agents.sh
```

### **Separate Workflows**
```bash
./stop.sh && docker compose build && ./deploy.sh && ./run-all-buyerseller-2.sh
# Then manually:
./run-agent-delegation-org1.sh
./run-agent-delegation-org2.sh
```

---

## ✅ Success Indicators

After running `run-all-buyerseller-2-with-agents.sh`, you should see:

```
✅ Setup Complete!

Summary:
  • GEDA (Root) and QVI established
  • 2 organizations processed:
    - Jupiter Knitting (1 person(s), 1 agent(s))
    - Tommy Hilfiger Europe (1 person(s), 1 agent(s))
  • All credentials issued and presented to verifier
  • ✨ 2 agent(s) delegated and verified
  • Trust tree visualization generated

✨ Agent Delegation Summary:
  • jupiterSellerAgent → Delegated from Jupiter_Chief_Sales_Officer
    AID: EAgent...
    Status: ✓ Verified by Sally
  • tommyBuyerAgent → Delegated from Tommy_Buyer_OOR
    AID: EAgent...
    Status: ✓ Verified by Sally

✨ vLEI credential system with agent delegation completed successfully!
```

---

## 🎉 You're Ready!

**Recommended approach:**
```bash
./stop.sh
docker compose build  
./deploy.sh
./run-all-buyerseller-2-with-agents.sh
```

This single command sequence will:
1. Stop everything cleanly
2. Build fresh container images
3. Deploy all services
4. Run the complete workflow including agent delegation

**That's it!** 🚀
