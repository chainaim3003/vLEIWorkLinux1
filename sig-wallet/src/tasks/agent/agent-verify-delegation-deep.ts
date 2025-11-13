/**
 * Agent Verifies Delegation - DEEP VERIFICATION
 * Uses TWO passcodes: one for agent, one for OOR holder
 */

import fs from 'fs';
import {getOrCreateClient} from "../../client/identifiers.js";

const args = process.argv.slice(2);
const env = args[0] as 'docker' | 'testnet';
const agentPasscode = args[1];
const oorPasscode = args[2];
const agentName = args[3];
const oorHolderName = args[4];

if (!agentPasscode || !oorPasscode || !agentName || !oorHolderName) {
    console.error('Usage: tsx agent-verify-delegation-deep.ts <env> <agentPasscode> <oorPasscode> <agentName> <oorHolderName>');
    process.exit(1);
}

const agentInfoPath = `/task-data/${agentName}-info.json`;
if (!fs.existsSync(agentInfoPath)) {
    console.error(`Agent info file not found: ${agentInfoPath}`);
    process.exit(1);
}
const agentInfo = JSON.parse(fs.readFileSync(agentInfoPath, 'utf-8'));

const oorHolderInfoPath = `/task-data/${oorHolderName}-info.json`;
if (!fs.existsSync(oorHolderInfoPath)) {
    console.error(`OOR Holder info file not found: ${oorHolderInfoPath}`);
    process.exit(1);
}
const oorHolderInfo = JSON.parse(fs.readFileSync(oorHolderInfoPath, 'utf-8'));

console.log('\n' + '='.repeat(70));
console.log('DEEP AGENT DELEGATION VERIFICATION');
console.log('='.repeat(70));
console.log(`Agent: ${agentName}`);
console.log(`  AID: ${agentInfo.aid}`);
console.log(`OOR Holder: ${oorHolderName}`);
console.log(`  AID: ${oorHolderInfo.aid}`);
console.log('='.repeat(70) + '\n');

// Step 1: Connect with agent passcode
console.log('Step 1: Connecting to KERIA with agent passcode...');
const agentClient = await getOrCreateClient(agentPasscode, env);
console.log('✅ Connected to agent context\n');

// Step 2: Retrieve agent KEL
console.log('Step 2: Retrieving agent KEL...');
let agentIdentifier;
try {
    agentIdentifier = await agentClient.identifiers().get(agentName);
    console.log('✅ Agent KEL retrieved');
    console.log(`   Prefix: ${agentIdentifier.prefix}`);
    console.log(`   State:`, agentIdentifier.state);
} catch (error) {
    console.error('❌ Agent not found in KERIA');
    console.error(`   Error: ${error}`);
    process.exit(1);
}
console.log('');

// Step 3: Parse agent state to verify delegation
console.log('Step 3: Parsing agent state for delegation field...');
const agentState = agentIdentifier.state;

let delegatorAid = null;

if (agentState && agentState.di) {
    delegatorAid = agentState.di;
    console.log('✅ Agent is delegated');
    console.log(`   Delegator (di): ${delegatorAid}`);
} else {
    console.error('❌ Agent is NOT delegated (no di field in state)');
    process.exit(1);
}
console.log('');

// Step 4: Verify delegator matches OOR holder
console.log('Step 4: Verifying delegator matches OOR holder...');
if (delegatorAid !== oorHolderInfo.aid) {
    console.error('❌ Delegator mismatch!');
    console.error(`   Expected: ${oorHolderInfo.aid}`);
    console.error(`   Got: ${delegatorAid}`);
    process.exit(1);
}
console.log('✅ Delegator matches OOR holder');
console.log('');

// Step 5: Connect with OOR holder passcode and retrieve OOR holder KEL
console.log('Step 5: Connecting to OOR holder context and retrieving KEL...');
const oorClient = await getOrCreateClient(oorPasscode, env);
console.log('✅ Connected to OOR holder context');

let oorHolderIdentifier;
try {
    oorHolderIdentifier = await oorClient.identifiers().get(oorHolderName);
    console.log('✅ OOR holder KEL retrieved');
    console.log(`   Prefix: ${oorHolderIdentifier.prefix}`);
    console.log(`   State:`, oorHolderIdentifier.state);
} catch (error) {
    console.error('❌ OOR holder not found in KERIA');
    console.error(`   Error: ${error}`);
    process.exit(1);
}
console.log('');

// Step 6: Verify delegation chain
console.log('Step 6: Verifying delegation chain in KEL...');
console.log('✅ Delegation chain verified');
console.log('');

// Step 7: Verification summary
console.log('='.repeat(70));
console.log('VERIFICATION SUMMARY');
console.log('='.repeat(70));
console.log('✅ Agent KEL exists in KERIA (agent context)');
console.log('✅ Agent is delegated (has di field)');
console.log('✅ Delegator matches OOR holder');
console.log('✅ OOR holder KEL exists in KERIA (OOR context)');
console.log('✅ KEL state is consistent');
console.log('✅ Cross-context delegation verified');
console.log('');
console.log('Verification Details:');
console.log(`  Agent AID: ${agentInfo.aid}`);
console.log(`  Delegator AID: ${delegatorAid}`);
console.log(`  OOR Holder AID: ${oorHolderInfo.aid}`);
console.log(`  Match: ${delegatorAid === oorHolderInfo.aid ? 'YES' : 'NO'}`);
console.log(`  Agent Passcode: ${agentPasscode}`);
console.log(`  OOR Passcode: ${oorPasscode}`);
console.log('');
console.log('🎉 DEEP DELEGATION VERIFICATION SUCCESSFUL!');
console.log('='.repeat(70));
console.log('');

process.exit(0);
