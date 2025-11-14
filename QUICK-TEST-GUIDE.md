# Quick Test Guide - Self-Attested Invoice Credentials

## Quick Start

### 1. Run Complete Workflow
```bash
cd /path/to/vLEIWorkLinux1
./run-all-buyerseller-4-with-agents.sh
```

This will:
- Set up GEDA, QVI, LEs, OORs, and Agents (same as script 3)
- Create self-attested invoice credential by jupiterSalesAgent
- Send IPEX grant to tommyBuyerAgent
- Complete the admit process
- Query credentials from both agents

### 2. Test Agent Verification with Credential Query
```bash
# Test Jupiter Sales Agent
./test-agent-verification-DEEP-credential.sh jupiterSalesAgent Jupiter_Chief_Sales_Officer true docker

# Test Tommy Buyer Agent  
./test-agent-verification-DEEP-credential.sh tommyBuyerAgent Tommy_Chief_Procurement_Officer true docker
```

## Individual Component Tests

### Test Invoice Creation Only
```bash
# 1. Create registry
./task-scripts/invoice/invoice-registry-create-agent.sh jupiterSalesAgent

# 2. Issue self-attested invoice
./task-scripts/invoice/invoice-acdc-issue-self-attested.sh \
    jupiterSalesAgent \
    ./appconfig/invoiceConfig.json

# 3. Admit self-attested invoice
./task-scripts/invoice/invoice-acdc-admit-self.sh jupiterSalesAgent
```

### Test IPEX Grant/Admit
```bash
# 1. Send grant
./task-scripts/invoice/invoice-ipex-grant.sh \
    jupiterSalesAgent \
    tommyBuyerAgent

# 2. Admit grant
./task-scripts/invoice/invoice-ipex-admit.sh \
    tommyBuyerAgent \
    jupiterSalesAgent
```

### Test Credential Query
```bash
# Query from seller agent
./task-scripts/invoice/invoice-query.sh jupiterSalesAgent

# Query from buyer agent
./task-scripts/invoice/invoice-query.sh tommyBuyerAgent
```

## Verification Commands

### Check Self-Attestation
```bash
# Verify issuer === issuee
cat task-data/jupiterSalesAgent-self-invoice-credential-info.json | jq '{issuer, issuee, selfAttested}'
```

Expected output:
```json
{
  "issuer": "EKergBY...",
  "issuee": "EKergBY...",
  "selfAttested": true
}
```

### Check No Edge
```bash
# Verify no edge to OOR
cat task-data/jupiterSalesAgent-self-invoice-credential-info.json | jq '.hasEdge'
```

Expected output: `false`

### Check IPEX Grant
```bash
# Check grant was sent
cat task-data/jupiterSalesAgent-self-invoice-credential-info.json | jq '.grantSaid'
```

Should show a SAID value (not null)

### Check Credential Query Results
```bash
# Seller side
cat task-data/jupiterSalesAgent-invoice-query-results.json | jq '{totalInvoices, invoices: [.invoices[] | {invoiceNumber, selfAttested}]}'

# Buyer side
cat task-data/tommyBuyerAgent-invoice-query-results.json | jq '{totalInvoices, invoices: [.invoices[] | {invoiceNumber, selfAttested}]}'
```

### Check Validation Results
```bash
# Seller side
cat task-data/jupiterSalesAgent-credential-validation-results.json | jq '{totalValid, totalInvalid, validationRate}'

# Buyer side
cat task-data/tommyBuyerAgent-credential-validation-results.json | jq '{totalValid, totalInvalid, validationRate}'
```

## Expected Test Results

### After run-all-buyerseller-4-with-agents.sh

#### jupiterSalesAgent Should Have:
- ✓ Invoice credential (self-attested)
- ✓ issuer === issuee === jupiterSalesAgent AID
- ✓ No edge to OOR
- ✓ Queryable from KERIA
- ✓ IPEX grant sent

#### tommyBuyerAgent Should Have:
- ✓ Invoice credential (received via IPEX)
- ✓ Original issuer: jupiterSalesAgent
- ✓ Queryable from KERIA
- ✓ IPEX admit completed

### After test-agent-verification-DEEP-credential.sh

#### Both Agents Should Show:
- ✓ Deep delegation verification passed
- ✓ Credentials queried successfully
- ✓ All credentials validated
- ✓ No validation errors

## Common Issues & Solutions

### Issue: "No invoice credential found"
**Cause**: Credential not created or admitted
**Solution**: 
```bash
# Check if registry exists
ls task-data/jupiterSalesAgent-invoice-registry-info.json

# Check if credential issued
ls task-data/jupiterSalesAgent-self-invoice-credential-info.json

# Re-run issue and admit
./task-scripts/invoice/invoice-acdc-issue-self-attested.sh jupiterSalesAgent ./appconfig/invoiceConfig.json
./task-scripts/invoice/invoice-acdc-admit-self.sh jupiterSalesAgent
```

### Issue: "No pending grant found"
**Cause**: IPEX grant not sent or already admitted
**Solution**:
```bash
# Check notifications
docker compose exec tsx-shell tsx -e "
import { getOrCreateClient } from './sig-wallet/src/client/identifiers.js';
const client = await getOrCreateClient('AgentPass123', 'docker');
const notes = await client.notifications().list();
console.log(JSON.stringify(notes, null, 2));
"

# Resend grant if needed
./task-scripts/invoice/invoice-ipex-grant.sh jupiterSalesAgent tommyBuyerAgent
```

### Issue: "Credential not self-attested"
**Cause**: Wrong issuer/holder values
**Solution**: Check the credential JSON:
```bash
cat task-data/jupiterSalesAgent-self-invoice-credential-info.json | jq '{issuer, issuee, selfAttested}'
```

If `selfAttested: false`, the credential was not created correctly. Re-create it.

### Issue: "Query returns 0 credentials"
**Cause**: Credential not in KERIA storage
**Solution**:
```bash
# Check if admit completed
docker compose exec tsx-shell tsx -e "
import { getOrCreateClient } from './sig-wallet/src/client/identifiers.js';
const client = await getOrCreateClient('AgentPass123', 'docker');
const aid = await client.identifiers().get('jupiterSalesAgent');
const creds = await client.credentials().list(aid.name);
console.log(\`Found \${creds.length} credentials\`);
"
```

## Test Data Cleanup

### Clean All Task Data
```bash
rm -rf task-data/*
```

### Clean Specific Agent Data
```bash
rm task-data/jupiterSalesAgent-*
rm task-data/tommyBuyerAgent-*
```

### Start Fresh
```bash
# Stop containers
docker compose down -v

# Clean task data
rm -rf task-data/*

# Restart
docker compose up -d

# Wait for services
sleep 10

# Run workflow
./run-all-buyerseller-4-with-agents.sh
```

## Monitoring & Logs

### Watch Docker Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f tsx-shell
docker compose logs -f keria
```

### Check KERIA Agent Status
```bash
docker compose exec tsx-shell tsx -e "
import { getOrCreateClient } from './sig-wallet/src/client/identifiers.js';
const client = await getOrCreateClient('AgentPass123', 'docker');
const aids = await client.identifiers().list();
console.log('Agents:', aids.map(a => a.name));
"
```

## Success Criteria

### Minimum Requirements
- [ ] run-all-buyerseller-4-with-agents.sh completes without errors
- [ ] jupiterSalesAgent has self-attested invoice (issuer === issuee)
- [ ] Invoice has no edge to OOR
- [ ] IPEX grant sent successfully
- [ ] tommyBuyerAgent received and admitted invoice
- [ ] Both agents can query the invoice

### Complete Validation
- [ ] All minimum requirements met
- [ ] test-agent-verification-DEEP-credential.sh passes for both agents
- [ ] Credential validation shows 100% valid
- [ ] Query results show correct invoice details
- [ ] Trust tree visualization generated

## Performance Notes

- Full workflow takes approximately: 2-5 minutes
- IPEX grant/admit: ~10 seconds
- Credential query: ~2 seconds
- Deep verification: ~30 seconds

## Next Steps After Success

1. Review trust tree: `cat task-data/trust-tree-buyerseller-self-attested.txt`
2. Examine credential details: `cat task-data/jupiterSalesAgent-self-invoice-credential-info.json | jq .`
3. Review validation results: `cat task-data/*-credential-validation-results.json | jq .`
4. Consider implementing additional features (revocation, multiple invoices, etc.)
