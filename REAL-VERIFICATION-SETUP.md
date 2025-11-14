# 🚀 REAL vLEI Agent Verification Setup Guide

This guide shows you how to connect your Windows UI to the real Linux backend verification system.

## 📋 Overview

**Before:** UI buttons showed fake "✅ Verified" messages (mock/simulation)  
**After:** UI buttons trigger REAL vLEI verification using Docker containers and KERI protocols

---

## 🏗️ Architecture

```
Windows UI (React/Next.js)
         ↓ HTTP POST
Linux API Server (Node.js/Express)
         ↓ Shell Script Execution
Docker Containers (KERI/vLEI)
         ↓ Verification Logic
Real Verification Results
```

---

## ⚙️ Setup Instructions

### Part 1: Linux Backend (API Server)

1. **Navigate to your project:**
   ```bash
   cd ~/projects/vLEIWorkLinux1
   ```

2. **Make the startup script executable:**
   ```bash
   chmod +x start-api-server.sh
   ```

3. **Start the API server:**
   ```bash
   ./start-api-server.sh
   ```

   You should see:
   ```
   ========================================
   Starting vLEI Verification API Server
   ========================================
   
   ✅ Starting API server...
   
   Server Information:
     Local:    http://localhost:4000
     Network:  http://192.168.x.x:4000
   
   Update your UI .env.local with:
     NEXT_PUBLIC_API_URL=http://192.168.x.x:4000
   ```

4. **Keep this terminal open** - The API server needs to stay running

5. **Note your IP address** - You'll need this for the UI configuration

---

### Part 2: Windows UI Configuration

1. **Open PowerShell/Command Prompt and navigate to UI directory:**
   ```powershell
   cd C:\CHAINAIM3003\mcp-servers\vLEIUI
   ```

2. **Copy the environment file:**
   ```powershell
   copy .env.local.example .env.local
   ```

3. **Edit `.env.local` and update the IP address:**
   ```env
   NEXT_PUBLIC_API_URL=http://192.168.x.x:4000
   ```
   Replace `192.168.x.x` with the IP shown by the API server

4. **Restart your UI development server:**
   ```powershell
   npm run dev
   ```

---

## 🧪 Testing the Connection

### Test 1: API Health Check

In a new terminal on Linux:
```bash
curl http://localhost:4000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2025-11-13T...",
  "message": "vLEI Verification API Server is running"
}
```

### Test 2: Manual Verification (Linux)

```bash
curl -X POST http://localhost:4000/api/verify/seller
```

This should trigger real verification and return results.

### Test 3: UI Button Click (Windows)

1. Open browser: http://localhost:3000
2. Click "Fetch My Agent Card" buttons
3. Click "Verify Seller Agent" or "Verify Buyer Agent"
4. Watch the browser console (F12) for real verification logs

---

## 🔍 How to Verify It's REAL (Not Mock)

### Signs of Real Verification:

1. **Takes longer** - Real verification takes 30-60 seconds (not 2.5 seconds)
2. **Console logs show:**
   ```
   🔐 Starting REAL seller agent verification...
   Verification result: { success: true, output: "..." }
   ✅ Seller agent verification PASSED
   ```
3. **API server terminal shows:**
   ```
   === SELLER AGENT VERIFICATION REQUEST ===
   Starting verification for: jupiterSellerAgent
   Executing: bash .../test-agent-verification-DEEP.sh ...
   Verification result: SUCCESS
   ```
4. **Can fail** - If Docker isn't running or agents don't exist, you'll see real error messages

### Signs of Mock/Fake Verification:

- ❌ Always succeeds (never fails)
- ❌ Takes exactly 2.5 seconds
- ❌ No console logs about API calls
- ❌ Works even when API server is off

---

## 🚨 Troubleshooting

### Problem: "Cannot connect to verification API"

**Cause:** API server not running or wrong IP address

**Solution:**
1. Check API server is running on Linux
2. Verify IP address in `.env.local` is correct
3. Check firewall isn't blocking port 4000

### Problem: "Verification Failed: Agent info file not found"

**Cause:** Agents haven't been created yet

**Solution:**
```bash
cd ~/projects/vLEIWorkLinux1
./demo-delegation-issuance.sh
```

Wait for issuance to complete, then try verification again.

### Problem: API server won't start

**Cause:** Port 4000 already in use

**Solution:**
```bash
# Find what's using port 4000
sudo lsof -i :4000

# Kill the process or change port in api-server/server.js
export PORT=4001
./start-api-server.sh
```

### Problem: UI still shows mock verification

**Cause:** Environment variable not loaded

**Solution:**
1. Stop UI dev server (Ctrl+C)
2. Delete `.next` folder: `rm -rf .next` (on Windows use `rmdir /s .next`)
3. Restart: `npm run dev`

---

## 📁 File Structure

```
vLEIWorkLinux1/
├── api-server/                          # NEW - API Server
│   ├── server.js                        # Main API server
│   ├── package.json                     # Dependencies
│   └── README.md                        # API documentation
├── start-api-server.sh                  # NEW - Easy startup script
├── demo-delegation-issuance.sh          # Create agents (existing)
└── demo-delegation-deep-verification.sh # Verify agents (existing)

vLEIUI/
├── app/
│   └── page.tsx                         # UPDATED - Real API calls
├── .env.local                           # NEW - API configuration
└── .env.local.example                   # NEW - Template
```

---

## ✅ Verification Checklist

Before clicking "Verify Agent" buttons:

- [ ] Docker containers are running on Linux
- [ ] Agents have been created (`./demo-delegation-issuance.sh`)
- [ ] API server is running (`./start-api-server.sh`)
- [ ] UI `.env.local` has correct IP address
- [ ] UI dev server restarted after changing `.env.local`
- [ ] Browser console shows real API calls (F12)

---

## 🎯 Quick Start (TL;DR)

**On Linux:**
```bash
cd ~/projects/vLEIWorkLinux1
./deploy.sh                    # Start Docker containers
./demo-delegation-issuance.sh  # Create agents (if not done)
./start-api-server.sh          # Start API server
```

**On Windows:**
```powershell
cd C:\CHAINAIM3003\mcp-servers\vLEIUI
# Edit .env.local with Linux IP
npm run dev
```

**In Browser:**
1. Go to http://localhost:3000
2. Click buttons
3. Watch REAL verification happen! 🎉

---

## 🔐 Security Notes

- API server listens on `0.0.0.0:4000` (all network interfaces)
- CORS enabled for all origins
- Only for development - don't expose to internet
- No authentication required (internal network only)

---

## 📞 Support

If verification fails:
1. Check Linux terminal (API server logs)
2. Check browser console (F12)
3. Check Docker containers: `docker ps`
4. Check agent files exist: `ls -la task-data/*agent*`

---

**You now have REAL vLEI verification! No more fake checkmarks! 🚀**
