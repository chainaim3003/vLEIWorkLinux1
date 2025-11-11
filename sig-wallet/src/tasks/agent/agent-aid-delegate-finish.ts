import fs from 'fs';
import {getOrCreateClient} from "../../client/identifiers.js";
import {waitOperation} from "../../client/operations.js";
import {SignifyClient} from "signify-ts";

// Pull in arguments from the command line and configuration
const args = process.argv.slice(2);
const env = args[0] as 'docker' | 'testnet';
const passcode = args[1];
const agentAidName = args[2];
const oorHolderInfoPath = args[3];
const agentInceptionInfoPath = args[4];
const agentOutputPath = args[5];

async function finishAgentDelegation(
    agentClient: SignifyClient,
    oorHolderPre: string,
    agentName: string,
    agentIcpOpName: string) {
    console.log(`Finishing ${agentName} delegation by OOR Holder ${oorHolderPre} on op: ${agentIcpOpName}...`);

    // refresh OOR Holder key state to discover delegation anchor
    const op: any = await agentClient.keyStates().query(oorHolderPre, '1');
    await waitOperation(agentClient, op);

    // wait for agent inception to complete
    const agentOp: any = await agentClient.operations().get(agentIcpOpName);
    await waitOperation(agentClient, agentOp);

    // finish identifier setup
    // add endpoint role
    const endRoleOp = await agentClient.identifiers()
        .addEndRole(agentName, 'agent', agentClient!.agent!.pre);
    await waitOperation(agentClient, await endRoleOp.op());

    // get oobi
    const oobiResp = await agentClient.oobis().get(agentName, 'agent');
    const oobi = oobiResp.oobis[0];

    const aid = await agentClient.identifiers().get(agentName);
    return {
        aid: aid.prefix,
        oobi
    }
}

const agentClient = await getOrCreateClient(passcode, env);

// Read OOR Holder info - use synchronous read
if (!fs.existsSync(oorHolderInfoPath)) {
    throw new Error(`OOR Holder info file not found: ${oorHolderInfoPath}`);
}
const oorHolderInfo = JSON.parse(fs.readFileSync(oorHolderInfoPath, 'utf-8'));

// Read agent inception info - use synchronous read
if (!fs.existsSync(agentInceptionInfoPath)) {
    throw new Error(`Agent inception info file not found: ${agentInceptionInfoPath}`);
}
const agentIcpInfo = JSON.parse(fs.readFileSync(agentInceptionInfoPath, 'utf-8'));
console.log(`${agentAidName} agent inception info`, agentIcpInfo);

// finish delegation and write data to file
const agentDelegationInfo: any = await finishAgentDelegation(
    agentClient, 
    oorHolderInfo.aid, 
    agentAidName, 
    agentIcpInfo.icpOpName
);

// Use synchronous write
fs.writeFileSync(agentOutputPath, JSON.stringify(agentDelegationInfo, null, 2));

// Verify file was written
if (!fs.existsSync(agentOutputPath)) {
    throw new Error(`Failed to write ${agentOutputPath}`);
}

console.log(`Agent delegation data written to ${agentOutputPath}`);
