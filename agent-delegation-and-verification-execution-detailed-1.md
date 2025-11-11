# Agent Delegation and Verification - Complete Executable Design

**Document Version:** 1.0  
**Date:** November 10, 2025  
**Status:** Ready for Implementation  
**Based On:** Official GLEIF documentation and existing vLEIWorkLinux1 codebase

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [Complete Project Structure](#3-complete-project-structure)
4. [TypeScript Implementation](#4-typescript-implementation)
5. [Shell Script Wrappers](#5-shell-script-wrappers)
6. [Sally Verifier Extension](#6-sally-verifier-extension)
7. [Docker Integration](#7-docker-integration)
8. [Step-by-Step Execution](#8-step-by-step-execution)
9. [Testing & Verification](#9-testing--verification)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Executive Summary

### What This Implements

This design implements **agent delegation** where AI agents (like `jupiterSellerAgent` and `tommyBuyerAgent`) are delegated **directly from their OOR (Official Organizational Role) holders**, and adds a **verification endpoint to Sally** to validate such delegations.

### Key Features

1. **Direct Delegation Pattern**: Agent AIDs delegated from OOR Holder AIDs (not from LE or QVI)
2. **Trust Chain Verification**: Agent → OOR Holder → OOR Credential → LE → QVI → GEDA
3. **Sally Extension**: New `/verify/agent-delegation` endpoint for automated verification
4. **Docker Integration**: Seamless integration with existing docker-compose setup
5. **No Mocks**: All code is production-ready and follows existing patterns

### Trust Chain

```
Agent AID (jupiterSellerAgent)
  |
  ├─ KEL Delegation: delpre = OOR Holder AID
  |                   ↓
  └─ OOR Holder: Chief Sales Officer (Jupiter)
       |
       └─ OOR Credential
            |
            └─ OOR Auth Credential
                 |
                 └─ LE Credential (Jupiter Knitting)
                      |
                      └─ QVI Credential
                           |
                           └─ GEDA (Root of Trust)
```

---

## 2. Architecture Overview

### Multi-Organization Agent Architecture

**Organization 1: JUPITER KNITTING COMPANY (Seller)**
```
GEDA (Root)
  └─> QVI (Delegated from GEDA)
       └─> LE: Jupiter Knitting - LEI: 3358004DXAMRWRUIYJ05
            └─> OOR Holder: Chief Sales Officer
                 ├─> OOR Credential (validated by QVI)
                 └─> jupiterSellerAgent (Delegated from OOR Holder)
```

**Organization 2: BUYER COMPANY**
```
GEDA (Root)
  └─> QVI (Delegated from GEDA)
       └─> LE: Buyer Company - LEI: [NEW]
            └─> OOR Holder: Tommy
                 ├─> OOR Credential (validated by QVI)
                 └─> tommyBuyerAgent (Delegated from OOR Holder)
```

### Delegation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ Step 1: Agent Initiates Delegation Request                     │
│   - Agent client creates delegation request to OOR Holder      │
│   - Creates agent-delegate-info.json with {aid, icpOpName}    │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 2: OOR Holder Approves Delegation                         │
│   - OOR Holder client anchors delegation in KEL                │
│   - Adds seal with agent AID to KEL                            │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 3: Agent Completes Delegation                             │
│   - Agent queries OOR Holder KEL for anchor                    │
│   - Completes inception                                        │
│   - Establishes endpoint role                                  │
│   - Generates OOBI                                             │
└─────────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 4: Sally Verifies Delegation                              │
│   - Checks agent KEL for delpre = OOR Holder AID               │
│   - Checks OOR Holder KEL for delegation seal                  │
│   - Verifies OOR Holder's OOR credential chain                 │
│   - Returns verification result                                │
└─────────────────────────────────────────────────────────────────┘
```

### Sally Verification Logic

```python
def verify_agent_delegation(agent_aid, oor_holder_aid):
    # 1. Get agent KEL
    agent_kever = hab.kevers.get(agent_aid)
    
    # 2. Verify agent has delpre field
    assert agent_kever.delpre == oor_holder_aid
    
    # 3. Get OOR Holder KEL
    oor_kever = hab.kevers.get(oor_holder_aid)
    
    # 4. Find delegation seal in OOR Holder KEL
    assert find_delegation_seal(oor_kever, agent_aid)
    
    # 5. Get OOR Holder's OOR credential
    oor_cred = get_oor_credential(oor_holder_aid)
    
    # 6. Verify OOR credential chain: OOR → OOR Auth → LE → QVI → GEDA
    verify_credential_chain(oor_cred)
    
    # 7. Check no credentials revoked
    assert not is_revoked(oor_cred)
    
    return {"valid": True, ...}
```

---

## 3. Complete Project Structure

### New Files and Directories

```
vLEIWorkLinux1/
├── sig-wallet/
│   └── src/
│       └── tasks/
│           ├── person/
│           │   ├── person-delegate-agent-create.ts       ← NEW
│           │   └── person-approve-agent-delegation.ts    ← NEW
│           └── agent/                                     ← NEW DIRECTORY
│               ├── agent-aid-delegate-finish.ts          ← NEW
│               ├── agent-oobi-resolve-qvi.ts             ← NEW
│               ├── agent-oobi-resolve-le.ts              ← NEW
│               ├── agent-oobi-resolve-verifier.ts        ← NEW
│               └── agent-verify-delegation.ts            ← NEW
│
├── task-scripts/
│   ├── person/
│   │   ├── person-delegate-agent-create.sh               ← NEW
│   │   └── person-approve-agent-delegation.sh            ← NEW
│   └── agent/                                             ← NEW DIRECTORY
│       ├── agent-aid-delegate-finish.sh                  ← NEW
│       ├── agent-oobi-resolve-qvi.sh                     ← NEW
│       ├── agent-oobi-resolve-le.sh                      ← NEW
│       ├── agent-oobi-resolve-verifier.sh                ← NEW
│       └── agent-verify-delegation.sh                    ← NEW
│
├── config/
│   └── verifier-sally/
│       ├── custom-sally/                                  ← NEW DIRECTORY
│       │   ├── agent_verifying.py                        ← NEW
│       │   ├── handling_ext.py                           ← NEW
│       │   └── __init__.py                               ← NEW
│       ├── entry-point-extended.sh                       ← NEW
│       └── verifier.json                                 ← MODIFY
│
├── run-agent-delegation-org1.sh                           ← NEW
├── run-agent-delegation-org2.sh                           ← NEW
└── docker-compose.yml                                     ← MODIFY
```

### File Dependency Map

```
Agent Delegation Workflow:
┌─────────────────────────────────────────────────────────┐
│ TypeScript Tasks (sig-wallet/src/tasks/)               │
├─────────────────────────────────────────────────────────┤
│ person-delegate-agent-create.ts                         │
│   ↓ creates agent-delegate-info.json                   │
│ person-approve-agent-delegation.ts                      │
│   ↓ anchors delegation in OOR Holder KEL               │
│ agent-aid-delegate-finish.ts                            │
│   ↓ creates agent-info.json                            │
│ agent-oobi-resolve-*.ts                                 │
│   ↓ resolves OOBIs                                      │
│ agent-verify-delegation.ts                              │
│   ↓ calls Sally API                                     │
└─────────────────────────────────────────────────────────┘
         ↓ wrapped by
┌─────────────────────────────────────────────────────────┐
│ Shell Scripts (task-scripts/)                          │
├─────────────────────────────────────────────────────────┤
│ *.sh files wrap TypeScript tasks                       │
│ Run via tsx-script-runner.sh                           │
└─────────────────────────────────────────────────────────┘
         ↓ verified by
┌─────────────────────────────────────────────────────────┐
│ Sally Verifier Extension                                │
├─────────────────────────────────────────────────────────┤
│ agent_verifying.py - Core verification logic            │
│ handling_ext.py - HTTP handler                          │
│ entry-point-extended.sh - Loads extensions              │
└─────────────────────────────────────────────────────────┘
```

---

## 4. TypeScript Implementation

### 4.1 Person/OOR Holder Tasks

#### File: `sig-wallet/src/tasks/person/person-delegate-agent-create.ts`

```typescript
/**
 * Person/OOR Holder Initiates Agent Delegation
 * 
 * This script creates a delegation request from an agent to an OOR holder.
 * The agent client initiates the delegation, and the OOR holder must approve it.
 * 
 * Pattern: Same as qvi-aid-delegate-create.ts
 * 
 * Usage:
 *   tsx person-delegate-agent-create.ts <env> <agentPasscode> <dataDir> <oorHolderName> <agentName>
 * 
 * Example:
 *   tsx person-delegate-agent-create.ts docker myAgentPass123 /task-data Jupiter_Chief_Sales_Officer jupiterSellerAgent
 * 
 * Creates:
 *   /task-data/jupiterSellerAgent-delegate-info.json
 *   {
 *     "aid": "EAgent...",
 *     "icpOpName": "delegation.EAgent..."
 *   }
 */

import fs from 'fs';
import {createDelegate, getOrCreateClient} from "../../client/identifiers.js";

const args = process.argv.slice(2);
const env = args[0] as 'docker' | 'testnet';
const agentPasscode = args[1];
const dataDir = args[2];
const oorHolderName = args[3];  // e.g., 'Jupiter_Chief_Sales_Officer'
const agentName = args[4];      // e.g., 'jupiterSellerAgent'

// Validate arguments
if (!env || !agentPasscode || !dataDir || !oorHolderName || !agentName) {
    console.error('Usage: tsx person-delegate-agent-create.ts <env> <agentPasscode> <dataDir> <oorHolderName> <agentName>');
    process.exit(1);
}

// Read OOR Holder info - use synchronous read
const oorHolderInfoPath = `${dataDir}/${oorHolderName}-info.json`;
if (!fs.existsSync(oorHolderInfoPath)) {
    throw new Error(`OOR Holder info file not found: ${oorHolderInfoPath}`);
}
const oorHolderInfo = JSON.parse(fs.readFileSync(oorHolderInfoPath, 'utf-8'));

console.log(`Creating agent ${agentName} as delegate of ${oorHolderName}`);
console.log(`OOR Holder AID: ${oorHolderInfo.aid}`);
console.log(`OOR Holder OOBI: ${oorHolderInfo.oobi}`);

// Agent client creates delegation request to OOR Holder
const agentClient = await getOrCreateClient(agentPasscode, env);
const clientInfo: any = await createDelegate(
    agentClient,
    agentName,              // delegate name
    oorHolderInfo.aid,      // delegator prefix (OOR Holder AID)
    oorHolderName,          // delegator alias name
    oorHolderInfo.oobi      // delegator OOBI
);

// Save agent delegation info - use synchronous write
const agentDelegateInfoPath = `${dataDir}/${agentName}-delegate-info.json`;
fs.writeFileSync(agentDelegateInfoPath, JSON.stringify(clientInfo, null, 2));

// Verify file was written
if (!fs.existsSync(agentDelegateInfoPath)) {
    throw new Error(`Failed to write ${agentDelegateInfoPath}`);
}

console.log(`Agent delegation info written to ${agentDelegateInfoPath}`);
console.log(`Agent AID: ${clientInfo.aid}`);
console.log(`ICP Operation: ${clientInfo.icpOpName}`);
console.log(`Delegation request sent to ${oorHolderName}`);
```

#### File: `sig-wallet/src/tasks/person/person-approve-agent-delegation.ts`

```typescript
/**
 * Person/OOR Holder Approves Agent Delegation
 * 
 * This script approves a delegation request from an agent.
 * The OOR holder anchors the delegation in their KEL with a seal.
 * 
 * Pattern: Same as geda-delegate-approve.ts
 * 
 * Usage:
 *   tsx person-approve-agent-delegation.ts <env> <oorHolderPasscode> <oorHolderName> <agentDelegateInfoPath>
 * 
 * Example:
 *   tsx person-approve-agent-delegation.ts docker myOORPass123 Jupiter_Chief_Sales_Officer /task-data/jupiterSellerAgent-delegate-info.json
 * 
 * Effect:
 *   - Anchors delegation seal in OOR Holder's KEL
 *   - Seal contains agent AID
 */

import {approveDelegation, getOrCreateClient} from "../../client/identifiers.js";
import fs from "fs";

const args = process.argv.slice(2);
const env = args[0] as 'docker' | 'testnet';
const oorHolderPasscode = args[1];
const oorHolderName = args[2];       // e.g., 'Jupiter_Chief_Sales_Officer'
const agentDelegateInfoPath = args[3];

// Validate arguments
if (!env || !oorHolderPasscode || !oorHolderName || !agentDelegateInfoPath) {
    console.error('Usage: tsx person-approve-agent-delegation.ts <env> <oorHolderPasscode> <oorHolderName> <agentDelegateInfoPath>');
    process.exit(1);
}

console.log(`Approving delegation from ${oorHolderName} to agent`);

// Read agent delegation info - use synchronous read
if (!fs.existsSync(agentDelegateInfoPath)) {
    throw new Error(`Agent delegate info file not found: ${agentDelegateInfoPath}`);
}
const agentInfo = JSON.parse(fs.readFileSync(agentDelegateInfoPath, 'utf-8'));

console.log(`Agent AID: ${agentInfo.aid}`);

// OOR Holder approves delegation
const oorHolderClient = await getOrCreateClient(oorHolderPasscode, env);
const approved = await approveDelegation(oorHolderClient, oorHolderName, agentInfo.aid);

console.log(`OOR Holder ${oorHolderName} approved delegation of agent ${agentInfo.aid}: ${approved}`);
```

---

### 4.2 Agent Tasks

#### File: `sig-wallet/src/tasks/agent/agent-aid-delegate-finish.ts`

```typescript
/**
 * Agent Completes Delegation
 * 
 * This script completes the delegation process after OOR holder approval.
 * It waits for the delegation anchor, completes inception, and establishes OOBI.
 * 
 * Pattern: Same as qvi-aid-delegate-finish.ts
 * 
 * Usage:
 *   tsx agent-aid-delegate-finish.ts <env> <agentPasscode> <agentName> <oorHolderInfoPath> <agentDelegateInfoPath> <agentOutputPath>
 * 
 * Example:
 *   tsx agent-aid-delegate-finish.ts docker myAgentPass123 jupiterSellerAgent /task-data/Jupiter_Chief_Sales_Officer-info.json /task-data/jupiterSellerAgent-delegate-info.json /task-data/jupiterSellerAgent-info.json
 * 
 * Creates:
 *   /task-data/jupiterSellerAgent-info.json
 *   {
 *     "aid": "EAgent...",
 *     "oobi": "http://keria:3902/oobi/EAgent.../agent/...",
 *     "delegator": "EC7pC...",
 *     "delegatorName": "Jupiter_Chief_Sales_Officer"
 *   }
 */

import fs from 'fs';
import {getOrCreateClient} from "../../client/identifiers.js";
import {waitOperation} from "../../client/operations.js";
import {SignifyClient} from "signify-ts";

// Pull in arguments from the command line
const args = process.argv.slice(2);
const env = args[0] as 'docker' | 'testnet';
const agentPasscode = args[1];
const agentName = args[2];           // e.g., 'jupiterSellerAgent'
const oorHolderInfoPath = args[3];
const agentDelegateInfoPath = args[4];
const agentOutputPath = args[5];

// Validate arguments
if (!env || !agentPasscode || !agentName || !oorHolderInfoPath || !agentDelegateInfoPath || !agentOutputPath) {
    console.error('Usage: tsx agent-aid-delegate-finish.ts <env> <agentPasscode> <agentName> <oorHolderInfoPath> <agentDelegateInfoPath> <agentOutputPath>');
    process.exit(1);
}

async function finishDelegation(
    agentClient: SignifyClient,
    oorHolderAid: string,
    agentName: string,
    icpOpName: string
) {
    console.log(`Finishing delegation from ${oorHolderAid} to ${agentName}`);
    console.log(`ICP Operation: ${icpOpName}`);

    // Refresh OOR Holder key state to discover delegation anchor
    console.log(`Querying OOR Holder key state...`);
    const ksOp: any = await agentClient.keyStates().query(oorHolderAid, '1');
    await waitOperation(agentClient, ksOp);

    // Wait for agent inception to complete
    console.log(`Waiting for agent inception to complete...`);
    const icpOp: any = await agentClient.operations().get(icpOpName);
    await waitOperation(agentClient, icpOp);

    // Add endpoint role
    console.log(`Adding endpoint role...`);
    const endRoleOp = await agentClient.identifiers()
        .addEndRole(agentName, 'agent', agentClient.agent!.pre);
    await waitOperation(agentClient, await endRoleOp.op());

    // Get OOBI
    console.log(`Getting OOBI...`);
    const oobiResp = await agentClient.oobis().get(agentName, 'agent');
    const oobi = oobiResp.oobis[0];

    // Get AID info
    const aid = await agentClient.identifiers().get(agentName);

    return {
        aid: aid.prefix,
        oobi: oobi
    };
}

// Read OOR Holder info - use synchronous read
if (!fs.existsSync(oorHolderInfoPath)) {
    throw new Error(`OOR Holder info file not found: ${oorHolderInfoPath}`);
}
const oorHolderInfo = JSON.parse(fs.readFileSync(oorHolderInfoPath, 'utf-8'));

// Read agent delegate info - use synchronous read
if (!fs.existsSync(agentDelegateInfoPath)) {
    throw new Error(`Agent delegate info file not found: ${agentDelegateInfoPath}`);
}
const agentDelegateInfo = JSON.parse(fs.readFileSync(agentDelegateInfoPath, 'utf-8'));

console.log(`Agent delegate info:`, agentDelegateInfo);

// Get agent client
const agentClient = await getOrCreateClient(agentPasscode, env);

// Finish delegation
const delegationInfo: any = await finishDelegation(
    agentClient,
    oorHolderInfo.aid,
    agentName,
    agentDelegateInfo.icpOpName
);

// Combine with OOR holder info
const agentInfo = {
    ...delegationInfo,
    delegator: oorHolderInfo.aid,
    delegatorName: oorHolderInfoPath.split('/').pop()?.replace('-info.json', '') || 'unknown'
};

// Write agent info - use synchronous write
fs.writeFileSync(agentOutputPath, JSON.stringify(agentInfo, null, 2));

// Verify file was written
if (!fs.existsSync(agentOutputPath)) {
    throw new Error(`Failed to write ${agentOutputPath}`);
}

console.log(`Agent info written to ${agentOutputPath}`);
console.log(`Delegation complete`);
console.log(`Agent AID: ${agentInfo.aid}`);
console.log(`Agent OOBI: ${agentInfo.oobi}`);
console.log(`Delegated from: ${agentInfo.delegator}`);
```

Due to character limit, I need to continue in the next response. Let me write the file in chunks...

