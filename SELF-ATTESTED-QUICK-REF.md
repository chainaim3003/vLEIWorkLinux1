# Quick Reference: Self-Attested Invoice Credentials

**Date:** November 14, 2025  
**Scripts:** run-all-buyerseller-4-with-agents.sh, test-agent-verification-DEEP-credential.sh

---

## 🚀 Quick Start

### 1. Run the System
```bash
./run-all-buyerseller-4-with-agents.sh
```

### 2. Verify Seller Agent
```bash
./test-agent-verification-DEEP-credential.sh \
  jupiterSalesAgent \
  Jupiter_Chief_Sales_Officer \
  true \
  docker
```

### 3. Verify Buyer Agent
```bash
./test-agent-verification-DEEP-credential.sh \
  tommyBuyerAgent \
  Tommy_Buyer_OOR \
  true \
  docker
```

---

## 📊 Key Differences: Script 3 vs Script 4

| Feature | Script 3 (Traditional) | Script 4 (Self-Attested) |
|---------|----------------------|--------------------------|
| **Issuer** | OOR Holder | Agent (jupiterSalesAgent) |
| **Issuee** | Buyer Agent | Agent itself (self-attested) |
| **OOR Chain** | Yes (Invoice → OOR) | No (standalone) |
| **IPEX** | Implicit | **Explicit grant/admit** |
| **Storage** | Buyer agent only | **Both agents** |
| **Queryable** | One agent | **Both agents** |

---

## 🔄 Workflow Comparison

### Traditional (Script 3)
```
OOR Holder creates registry
    ↓
OOR Holder issues invoice to buyer agent
    ↓
Invoice references OOR credential (edge)
    ↓
Buyer agent admits
    ↓
Buyer agent can query

Trust: Invoice → OOR → LE → QVI → Root
```

### Self-Attested (Script 4)
```
Agent creates registry
    ↓
Agent issues invoice to ITSELF
    ↓
No OOR reference (self-attested)
    ↓
Agent admits self-attested credential
    ↓
Agent sends IPEX grant to buyer agent
    ↓
Buyer agent admits IPEX grant
    ↓
Both agents can query

Trust: Agent → OOR → LE → QVI → Root
```

---

## ✅ Verification Checklist

### After Running Script 4

- [ ] GEDA and QVI created
- [ ] Both Legal Entities created
- [ ] Both OOR credentials issued
- [ ] Both agents delegated
- [ ] jupiterSalesAgent created self-attested invoice
- [ ] IPEX grant sent
- [ ] tommyBuyerAgent admitted grant
- [ ] Both agents can query credential
- [ ] Credential validation passes

---

## 📁 Required Task Scripts

### Must be implemented:
1. `invoice-registry-create-agent.sh` - Create registry in agent
2. `invoice-acdc-issue-self-attested.sh` - Self-attest invoice
3. `invoice-acdc-admit-self.sh` - Agent admits own credential
4. `invoice-ipex-grant.sh` - Send IPEX grant
5. `invoice-ipex-admit.sh` - Admit IPEX grant
6. `invoice-query.sh` - Query credentials
7. `agent-query-credentials.ts` - Query for verification
8. `agent-validate-credentials.ts` - Validate credentials

---

## 🎯 Expected Output

### Script 4 Success
```
✓ GEDA & QVI setup complete
✓ All organizations processed
✓ All agents delegated and verified
✓ Self-Attested Invoice Workflow Complete
✓ Credential verified in both agents' KERIA

📄 Invoice Summary (Self-Attested):
  Issuer: jupiterSalesAgent (SELF-ATTESTED)
  Issuee: jupiterSalesAgent
  Granted to: tommyBuyerAgent via IPEX
```

### Verification Success
```
✅ Summary for jupiterSalesAgent:
  ✓ Deep agent delegation verification
  ✓ Credential query from KERIA
  ✓ Credential validation and proof verification

🎉 ALL VERIFICATIONS PASSED!
```

---

## 🐛 Common Issues

### Invoice not created
- **Check:** Agent delegation succeeded
- **Check:** Registry created in agent KERIA
- **Check:** Invoice config JSON is valid

### IPEX grant fails
- **Check:** Both agents have resolved OOBIs
- **Check:** Sender admitted credential first
- **Check:** Network connectivity between agents

### Query returns empty
- **Check:** Credential was admitted
- **Check:** Agent passcode is correct
- **Check:** KERIA is accessible

---

## 📚 Documentation

- **Full Guide:** SELF-ATTESTED-INVOICE-IMPLEMENTATION-GUIDE.md
- **Task Scripts:** task-scripts/invoice/
- **Configuration:** appconfig/invoiceConfig.json
- **Previous Chat:** [View context](https://claude.ai/chat/03c14162-a7e3-4668-9760-f4d4dcf8db27)

---

## 🔑 Key Commands

```bash
# Make executable (Linux/Mac)
chmod +x run-all-buyerseller-4-with-agents.sh
chmod +x test-agent-verification-DEEP-credential.sh

# Run full system
./run-all-buyerseller-4-with-agents.sh

# Verify with credentials
./test-agent-verification-DEEP-credential.sh \
  jupiterSalesAgent \
  Jupiter_Chief_Sales_Officer \
  true \
  docker

# Verify without credentials
./test-agent-verification-DEEP-credential.sh \
  jupiterSalesAgent \
  Jupiter_Chief_Sales_Officer \
  false \
  docker

# Query specific agent
./task-scripts/invoice/invoice-query.sh jupiterSalesAgent

# View results
cat ./task-data/jupiterSalesAgent-credential-query-results.json | jq '.'
cat ./task-data/jupiterSalesAgent-credential-validation-results.json | jq '.'
```

---

**For complete details, see SELF-ATTESTED-INVOICE-IMPLEMENTATION-GUIDE.md**
