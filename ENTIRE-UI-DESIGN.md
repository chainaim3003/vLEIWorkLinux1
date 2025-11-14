# Complete vLEI UI System - Entire Design Document

## 🎯 System Overview

This document provides the complete, comprehensive design for a full-featured vLEI credential system with both issuance and verification capabilities through a React TypeScript UI.

```
┌──────────────────────────────────────────────────────────────┐
│                    COMPLETE ARCHITECTURE                      │
├──────────────────────────────────────────────────────────────┤
│  1. CLI Workflow (Optional)                                  │
│     └─> demo-delegation-issuance.sh                         │
│                                                               │
│  2. Backend API (Node.js + Express)                          │
│     ├─> Docker Management                                    │
│     ├─> Issuance Orchestration                               │
│     └─> Verification Execution                               │
│                                                               │
│  3. Frontend UI (React + TypeScript)                         │
│     ├─> Docker Status Dashboard                              │
│     ├─> Issuance Workflow (Optional)                         │
│     ├─> Verification Interface                               │
│     └─> Results & Payment Display                            │
│                                                               │
│  4. Docker Infrastructure (WSL2)                             │
│     ├─> KERIA (3902)                                         │
│     ├─> Verification Service (9724)                          │
│     ├─> Witnesses, Schema, Sally                             │
│     └─> Task Data Volume                                     │
└──────────────────────────────────────────────────────────────┘
```

---

## 📚 Table of Contents

1. [Architecture Patterns](#architecture-patterns)
2. [Backend Implementation](#backend-implementation)
3. [Frontend Components](#frontend-components)
4. [Complete Workflows](#complete-workflows)
5. [Deployment Guide](#deployment-guide)

---

## 🏗 Architecture Patterns

### Pattern 1: CLI-Only Issuance + UI Verification

**Use Case**: Simple verification interface with manual parameter entry

```
CLI (demo-delegation-issuance.sh)
  ↓ Creates agents & credentials
Docker (WSL2)
  ↓ Provides verification services
Backend API
  ↓ Executes verification
Frontend UI
  └─> Verification form + Results display
```

**See**: CLI-UI-DESIGN.md for details

### Pattern 2: Full UI Issuance + Verification

**Use Case**: Complete UI for both credential issuance and verification

```
Frontend UI
  ├─> Issuance Wizard
  │   ├─> Organization Setup
  │   ├─> Person Setup
  │   └─> Agent Creation
  │
  └─> Verification Dashboard
      ├─> Agent Selection
      ├─> Verification Execution
      └─> Payment Processing
```

### Pattern 3: Hybrid Approach (Recommended)

**Use Case**: CLI for bulk operations, UI for individual verification

```
CLI: Batch issuance for production setup
UI:  Individual agent verification + payment
```

---

## 🖥️ Backend Implementation

### Complete Backend Structure

```
backend/
├── package.json
├── tsconfig.json
├── .env
├── src/
│   ├── server.ts                    # Main Express server
│   ├── controllers/
│   │   ├── dockerController.ts      # Docker status & management
│   │   ├── verificationController.ts # Verification logic
│   │   └── issuanceController.ts    # Issuance orchestration (optional)
│   ├── services/
│   │   ├── dockerService.ts
│   │   └── keriaService.ts
│   └── types/
│       └── index.ts
```

### Key Backend Endpoints

```typescript
// Health & Status
GET  /api/health
GET  /api/docker/status
GET  /api/docker/agents
GET  /api/docker/entity/:entityName

// Verification (Primary Feature)
POST /api/verify/agent
GET  /api/verify/history

// Issuance (Optional)
POST /api/issuance/run
GET  /api/issuance/status/:jobId
```

### Verification Controller (Core)

```typescript
// POST /api/verify/agent
// Executes: test-agent-verification-DEEP.sh

Request Body:
{
  "agentName": "jupiterSellerAgent",
  "oorHolderName": "Jupiter_Chief_Sales_Officer",
  "agentPasscode": "AgentPass123",
  "oorPasscode": "0ADckowyGuNwtJUPLeRqZvTp",
  "environment": "docker"
}

Response:
{
  "success": true,
  "verified": true,
  "agentAID": "EHHn...",
  "delegatorAID": "EJbZ...",
  "oorHolderAID": "EJbZ...",
  "match": true,
  "steps": [...],
  "timestamp": "2025-11-13T..."
}
```

---

## 🎨 Frontend Components

### Component Structure

```
frontend/src/
├── App.tsx                      # Main app with navigation
├── components/
│   ├── DockerStatus.tsx         # Docker monitoring (always visible)
│   ├── VerificationForm.tsx     # Main verification interface
│   ├── VerificationResult.tsx   # Results display
│   ├── PaymentMessage.tsx       # Payment confirmation
│   ├── VerificationHistory.tsx  # History list
│   └── IssuanceWizard.tsx       # Issuance UI (optional)
├── services/
│   └── api.ts                   # API client
└── styles/
    └── App.css                  # Complete styles
```

### Core Features

#### 1. Docker Status Component
- Real-time monitoring (updates every 10 seconds)
- Service health indicators
- Visual status: 🟢 Healthy | 🟡 Starting | 🔴 Down
- Shows all services: KERIA, verification, schema, witnesses, etc.

#### 2. Verification Form
- Manual parameter entry
- Dropdown selection from available agents
- Passcode inputs (secure)
- Environment selection (docker/testnet)
- Real-time validation

#### 3. Verification Result
- Detailed verification steps
- AID display (agent, delegator, OOR holder)
- Match confirmation
- Timestamp tracking

#### 4. Payment Message (On Success)
```
✅ Verification Complete - Ready for Payment

Agent successfully verified and authorized.

🚀 Initiating Stablecoin Payment

Transaction Flow:
1. ✅ Agent delegation verified via KERI
2. ✅ Credential chain validated
3. ⏳ Stablecoin payment initiated
4. ⏳ On-chain transaction recording
5. ⏱️ Awaiting blockchain confirmation

📝 Transaction will be recorded on-chain for full auditability
```

#### 5. Verification History
- List of all past verifications
- Success/failure indicators
- Searchable and filterable
- Timestamp sorted

---

## 🚀 Complete Workflows

### Workflow 1: CLI Issuance → UI Verification (Recommended)

```bash
# Step 1: CLI Issuance (WSL)
cd ~/projects/vLEIWorkLinux1
./demo-delegation-issuance.sh

# Step 2: Extract parameters
cat task-data/jupiterSellerAgent-info.json
cat task-data/Jupiter_Chief_Sales_Officer-info.json

# Step 3: Start backend (Windows)
cd backend
npm run dev

# Step 4: Start frontend (Windows)
cd frontend
npm start

# Step 5: Use UI
# - Check Docker status
# - Enter parameters
# - Verify agent
# - See payment message
```

### Workflow 2: Full UI Workflow (Optional)

```
1. Open UI (http://localhost:3000)
2. Check Docker Status → Should be 🟢
3. Go to "Issuance" tab (if enabled)
4. Click "Start Issuance"
5. Wait for completion
6. Go to "Verification" tab
7. Select agent from dropdown
8. Enter passcodes
9. Click "Verify"
10. See payment message on success
```

### Workflow 3: Continuous Monitoring

```
1. Docker Status updates every 10 seconds
2. Verification History auto-refreshes
3. Multiple verifications tracked
4. Payment messages shown for each success
```

---

## 📦 Deployment Guide

### Prerequisites

- ✅ WSL2 with Docker installed
- ✅ Node.js 18+ on Windows
- ✅ vLEI project already set up
- ✅ Docker containers running

### Step 1: Create Project Structure

```bash
# Create backend
mkdir backend
cd backend
npm init -y
npm install express cors typescript ts-node-dev @types/express @types/cors @types/node

# Create frontend
cd ..
npx create-react-app frontend --template typescript
cd frontend
npm install
```

### Step 2: Backend Setup

Create `backend/src/server.ts`:
```typescript
import express from 'express';
import cors from 'cors';

const app = express();
const port = 4000;

app.use(cors({ origin: 'http://localhost:3000' }));
app.use(express.json());

// Add controllers here

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
```

Create `backend/package.json` scripts:
```json
{
  "scripts": {
    "dev": "ts-node-dev --respawn src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js"
  }
}
```

### Step 3: Frontend Setup

Update `frontend/src/App.tsx`:
```typescript
import React from 'react';
import { DockerStatus } from './components/DockerStatus';
import { VerificationForm } from './components/VerificationForm';

function App() {
  return (
    <div className="App">
      <h1>vLEI Verification System</h1>
      <DockerStatus />
      <VerificationForm />
    </div>
  );
}

export default App;
```

### Step 4: Environment Configuration

Create `backend/.env`:
```
PORT=4000
VLEI_PROJECT_PATH=C:\SATHYA\CHAINAIM3003\mcp-servers\stellarboston\vLEI1\vLEIWorkLinux1
CORS_ORIGIN=http://localhost:3000
```

### Step 5: Run Everything

```bash
# Terminal 1: Backend
cd backend
npm run dev

# Terminal 2: Frontend
cd frontend
npm start

# Terminal 3: Check Docker (WSL)
cd ~/projects/vLEIWorkLinux1
docker compose ps
```

---

## 🎯 Key Features Summary

### ✅ Docker Management
- Real-time status monitoring
- Health checks for all services
- Visual indicators
- Start/stop controls (optional)

### ✅ Verification (Core Feature)
- Manual parameter entry from CLI logs
- DEEP KEL-based verification
- Real-time step display
- Detailed results

### ✅ Payment Message
- Displayed on verification success
- Stablecoin payment workflow
- On-chain transaction messaging
- Professional UI/UX

### ✅ History & Tracking
- All verifications tracked
- Timestamp sorted
- Success/failure indicators
- Searchable list

### ✅ Optional Features
- Issuance wizard UI
- Individual agent creation
- Direct KERIA API calls
- Batch operations

---

## 📊 API Reference

### Verification Endpoint

```
POST /api/verify/agent

Request:
{
  "agentName": "jupiterSellerAgent",
  "oorHolderName": "Jupiter_Chief_Sales_Officer",
  "agentPasscode": "AgentPass123",
  "oorPasscode": "0ADckowyGuNwtJUPLeRqZvTp",
  "environment": "docker"
}

Response (Success):
{
  "success": true,
  "verified": true,
  "agentAID": "EHHnC7rd40nPJf3kk6FEyYAPqwFpOLrBNfQtPJVoIcyn",
  "delegatorAID": "EJbZcL1qBh-x06SyZyM_hPGmvNUP2eNOLj4A6DPWX_Ak",
  "oorHolderAID": "EJbZcL1qBh-x06SyZyM_hPGmvNUP2eNOLj4A6DPWX_Ak",
  "match": true,
  "steps": [
    "Step 1: Connecting to KERIA...",
    "Step 2: Retrieving agent KEL...",
    "Step 3: Verifying delegation..."
  ],
  "timestamp": "2025-11-13T10:30:45.123Z"
}
```

### Docker Status Endpoint

```
GET /api/docker/status

Response:
{
  "success": true,
  "dockerRunning": true,
  "allServicesHealthy": true,
  "services": [
    {
      "name": "keria",
      "status": "running",
      "healthy": true,
      "ports": ["3901", "3902", "3903"]
    },
    {
      "name": "vlei-verification",
      "status": "running",
      "healthy": true,
      "ports": ["9724"]
    }
  ],
  "timestamp": "2025-11-13T10:30:45.123Z"
}
```

---

## 🔒 Security Considerations

### Production Checklist

✅ **Environment Variables**
- Store sensitive paths securely
- Use .env files (not committed)
- Rotate secrets regularly

✅ **Authentication** (For Production)
- JWT tokens for API access
- Role-based access control
- Session management

✅ **Input Validation**
- Sanitize all user inputs
- Validate AID formats (44 chars, starts with 'E')
- Rate limiting on endpoints

✅ **Passcode Security**
- Never store passcodes in frontend
- Use secure backend vault in production
- Consider encrypted storage

✅ **HTTPS**
- Use TLS in production
- Secure cookie flags
- CORS restrictions

---

## 📝 Summary

### What This Complete System Provides

✅ **CLI-based issuance** via demo-delegation-issuance.sh
✅ **Docker status monitoring** in real-time
✅ **Manual parameter entry** from logs/scripts
✅ **DEEP verification** execution
✅ **Payment message** on verification success
✅ **Verification history** tracking
✅ **Optional issuance UI** for convenience
✅ **Production-ready** architecture

### Architecture Benefits

1. **Flexibility**: Multiple issuance methods (CLI or UI)
2. **Simplicity**: UI focuses on verification
3. **Reliability**: Production-tested CLI scripts
4. **Scalability**: Async processing for long operations
5. **Monitoring**: Real-time Docker status
6. **Professional**: Payment workflow integration

### Recommended Approach

For most use cases, use **Pattern 1** (CLI Issuance + UI Verification):
- Run `./demo-delegation-issuance.sh` for batch operations
- Use UI for individual agent verification
- Display payment message on success
- Track verification history

This provides the best balance of:
- ✅ Reliability (proven CLI scripts)
- ✅ User Experience (clean UI)
- ✅ Flexibility (manual parameter control)
- ✅ Production-readiness (tested workflows)

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-13  
**For**: vLEIWorkLinux1 v1.0.9  
**Coverage**: Complete End-to-End System
