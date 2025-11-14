# Self-Attested Invoice Credential Implementation Summary

## Overview
This implementation modifies the vLEI credential system to support **self-attested invoice credentials** issued by agents, rather than being chained to OOR credentials.

## Key Changes from run-all-buyerseller-3-with-agents.sh

### Previous Approach (Script 3)
- **Issuer**: Jupiter_Chief_Sales_Officer (OOR Holder)
- **Holder**: tommyBuyerAgent  
- **Edge**: References OOR credential (I2I chain)
- **Trust Chain**: Invoice → OOR → LE → QVI → Root

### New Approach (Script 4)
- **Issuer**: jupiterSalesAgent (SELF-ATTESTED)
- **Holder**: jupiterSalesAgent (SAME as issuer)
- **Edge**: NONE (no OOR reference)
- **Trust Chain**: Agent delegation only (agent → OOR → LE → QVI → Root)
- **Sharing**: Via IPEX grant to tommyBuyerAgent

## New Files Created

### Shell Scripts
1. **invoice-acdc-admit-self.sh** - Agent admits its own self-attested credential
2. **invoice-query.sh** - Query invoice credentials from KERIA agent
3. **invoice-acdc-issue-self-attested.sh** - Updated to create only self-attested credential

### TypeScript Implementation Files
1. **invoice-acdc-issue-self-attested-only.ts** - Creates self-attested invoice (issuer = issuee)
2. **invoice-acdc-admit-self.ts** - Admits self-attested credential
3. **invoice-query.ts** - Queries invoice credentials from KERIA
4. **invoice-ipex-admit.ts** - Admits IPEX grant from another agent
5. **agent-query-credentials.ts** - Query all credentials from agent's KERIA
6. **agent-validate-credentials.ts** - Validate credential structure and proofs

## Workflow Steps

### 1. Invoice Creation (jupiterSalesAgent)
```bash
# Step 1: Create registry
./task-scripts/invoice/invoice-registry-create-agent.sh "jupiterSalesAgent" "JUPITER_AGENT_INVOICE_REGISTRY"

# Step 2: Issue self-attested credential
./task-scripts/invoice/invoice-acdc-issue-self-attested.sh \
    "jupiterSalesAgent" \
    "./appconfig/invoiceConfig.json"

# Step 3: Admit self-attested credential
./task-scripts/invoice/invoice-acdc-admit-self.sh "jupiterSalesAgent"
```

### 2. IPEX Grant to Buyer Agent
```bash
# Step 4: Send IPEX grant
./task-scripts/invoice/invoice-ipex-grant.sh \
    "jupiterSalesAgent" \
    "tommyBuyerAgent"

# Step 5: Buyer admits grant
./task-scripts/invoice/invoice-ipex-admit.sh \
    "tommyBuyerAgent" \
    "jupiterSalesAgent"
```

### 3. Query and Verify
```bash
# Query from seller agent
./task-scripts/invoice/invoice-query.sh "jupiterSalesAgent"

# Query from buyer agent
./task-scripts/invoice/invoice-query.sh "tommyBuyerAgent"
```

## Test Scripts

### Basic Test
Run the complete workflow:
```bash
./run-all-buyerseller-4-with-agents.sh
```

### Deep Verification with Credential Query
```bash
# Test agent delegation + credential query/validation
./test-agent-verification-DEEP-credential.sh jupiterSalesAgent Jupiter_Chief_Sales_Officer true docker
./test-agent-verification-DEEP-credential.sh tommyBuyerAgent Tommy_Chief_Procurement_Officer true docker
```

## Credential Structure

### Self-Attested Invoice
```json
{
  "v": "ACDC10JSON...",
  "d": "<SAID>",
  "i": "<jupiterSalesAgent AID>",  // Issuer
  "s": "<Invoice Schema SAID>",
  "a": {
    "i": "<jupiterSalesAgent AID>",  // Holder (SAME as issuer)
    "invoiceNumber": "INV-2025-001",
    "totalAmount": 25000,
    "currency": "USD",
    "sellerLEI": "3358004DXAMRWRUIYJ05",
    "buyerLEI": "54930012QJWZMYHNJW95",
    "paymentChainID": "stellar-testnet",
    "paymentWalletAddress": "GCYH...",
    ...
  },
  "e": {},  // NO EDGE - self-attested
  "r": {
    "d": "",
    "usageDisclaimer": {...},
    "invoiceTerms": {...},
    "selfAttestation": {...}
  }
}
```

### Key Properties
- **Issuer = Holder**: Self-attested
- **No Edge Section**: Not chained to OOR
- **Trust**: Through agent delegation chain
- **IPEX**: Shared via grant/admit protocol

## Query Results

### jupiterSalesAgent Credentials
- Self-attested invoice (issuer = jupiterSalesAgent)
- Queryable from KERIA
- No edge to OOR

### tommyBuyerAgent Credentials  
- Received invoice via IPEX
- Original issuer: jupiterSalesAgent
- Queryable from KERIA

## Validation Points

### test-agent-verification-DEEP-credential.sh Performs:
1. **Deep Agent Delegation Verification**
   - Agent AID validity
   - KEL seal verification
   - Delegation chain integrity
   - OOBI resolution

2. **Credential Query**
   - List all credentials
   - Extract invoice details
   - Check self-attestation
   - Verify edge structure

3. **Credential Validation**
   - SAID validation
   - Schema validation
   - Issuer validation
   - Chain validation (if applicable)
   - Attribute validation
   - Signature verification

## Important Notes

1. **Self-Attestation**: The credential's trust comes from the agent delegation chain, NOT from credential chaining
   
2. **IPEX Protocol**: Used for sharing credentials between agents
   - Grant: Sender offers credential
   - Admit: Receiver accepts credential

3. **KERIA Storage**: All credentials stored in respective agent's KERIA
   - jupiterSalesAgent: Original self-attested credential
   - tommyBuyerAgent: Received credential copy

4. **No OOR Chain**: Unlike script 3, invoice does NOT reference OOR credential
   - Trust derives from: Agent → OOR Holder → LE → QVI → Root
   - NOT from: Invoice → OOR → LE → QVI → Root

## Differences Summary Table

| Aspect | Script 3 | Script 4 |
|--------|----------|----------|
| Issuer | OOR Holder (person) | jupiterSalesAgent (agent) |
| Holder | tommyBuyerAgent | jupiterSalesAgent (self) |
| Edge | OOR credential | NONE |
| Chain | Invoice→OOR→LE→QVI→Root | Agent→OOR→LE→QVI→Root |
| Sharing | Direct issuance | IPEX grant/admit |
| Query | From holder only | From both agents |

## Testing Checklist

- [ ] Run run-all-buyerseller-4-with-agents.sh successfully
- [ ] Verify self-attested credential created (issuer = issuee)
- [ ] Verify no edge to OOR credential
- [ ] Verify IPEX grant sent successfully
- [ ] Verify IPEX admit completed
- [ ] Query credential from jupiterSalesAgent
- [ ] Query credential from tommyBuyerAgent
- [ ] Run deep verification with credential validation
- [ ] Verify all validation checks pass

## Expected Output Files

After successful execution:
- `task-data/jupiterSalesAgent-invoice-registry-info.json`
- `task-data/jupiterSalesAgent-self-invoice-credential-info.json`
- `task-data/jupiterSalesAgent-invoice-query-results.json`
- `task-data/tommyBuyerAgent-invoice-query-results.json`
- `task-data/jupiterSalesAgent-credential-query-results.json`
- `task-data/tommyBuyerAgent-credential-query-results.json`
- `task-data/jupiterSalesAgent-credential-validation-results.json`
- `task-data/tommyBuyerAgent-credential-validation-results.json`
- `trust-tree-buyerseller-self-attested.txt`

## Troubleshooting

### Issue: Credential not self-attested
**Check**: Verify issuer === issuee in credential info
**Solution**: Ensure invoice-acdc-issue-self-attested-only.ts uses issuerPrefix for both

### Issue: IPEX grant not received
**Check**: Notifications in receiver's KERIA
**Solution**: Verify sender sent grant before receiver admits

### Issue: Credential not queryable
**Check**: Credential storage in KERIA
**Solution**: Verify admit step completed successfully

## Next Steps

1. Test the complete workflow with run-all-buyerseller-4-with-agents.sh
2. Verify deep agent verification with credential validation
3. Query and validate credentials from both agents
4. Review trust tree visualization
5. Consider adding:
   - Credential revocation
   - Multiple invoice support
   - Enhanced validation rules
   - Schema versioning
